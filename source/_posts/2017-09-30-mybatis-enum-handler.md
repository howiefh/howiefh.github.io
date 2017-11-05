title: MyBatis 类型处理器
date: 2017-09-30 17:44:42
tags: [Java, MyBatis]
categories:
- Java
- MyBatis
description: MyBatis 类型处理器, MyBatis, 类型处理器, 枚举
---

## 问题描述

最近测试将 MyBatis 从 3.1.1 升级到 3.2.3 时遇到一个问题。原来可以正常工作的枚举类型处理器，抛异常了。

```
Caused by: org.apache.ibatis.executor.result.ResultMapException: Error attempting to get column 'member_type' from result set.  Cause: java.lang.IllegalArgumentException: No enum code 'MERCHANT'. class com...ChangeSceneType
```

涉及的代码及配置信息如下：

<!-- more -->

mybatis-config.xml :
```
<typeAliases>
    <typeAlias type="com...CodeEnumTypeHandler" alias="enumHandler" />
</typeAliases>

<typeHandlers>
    <!-- 其他枚举配置... -->
    <typeHandler handler="com...CodeEnumTypeHandler" javaType="com...MemberType" />
    <!-- 其他枚举配置... -->
    <typeHandler handler="com...CodeEnumTypeHandler" javaType="com...ChangeSceneType" />
</typeHandlers>
```

Mapper:
```
<resultMap id="XxxMap" type="com...XxxEntity">
    <!-- 其他属性配置... -->
    <result column="member_type" property="memberType" jdbcType="VARCHAR" typeHandler="enumHandler"/>
    <!-- 其他属性配置... -->
</resultMap>
```

CodeEnumTypeHandler.java:
```
public class CodeEnumTypeHandler<E extends Enum & CodeEnum> extends BaseTypeHandler<E> {

    private Class<E> type;

    private Map<String, E> enums;

    public CodeEnumTypeHandler(Class<E> type) {
        this.type = type;
        E[] es = type.getEnumConstants();
        if (es == null || es.length==0) {
            throw new IllegalArgumentException(type.getSimpleName() + " does not represent an enum type.");
        }
        enums = new HashMap<String, E>();
        for (E e: es) {
            enums.put(e.getCode(), e);
        }
    }

    private E valueOf(String code) {
        if (code == null) {
            return null;
        }
        E e = enums.get(code);
        if (e == null) {
            throw new IllegalArgumentException("No enum code '" + code + "'. " + type);
        }
        return e;
    }

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, E e, JdbcType jdbcType)
            throws SQLException {
        ps.setString(i, e.getCode());
    }

    @Override
    public E getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return valueOf(value);
    }

    @Override
    public E getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return valueOf(value);
    }

    @Override
    public E getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return valueOf(value);
    }
}
```

## 定位问题

```
1. org.apache.ibatis.builder.xml.XMLMapperBuilder#resultMapElement(org.apache.ibatis.parsing.XNode, java.util.List<org.apache.ibatis.mapping.ResultMapping>)
2. org.apache.ibatis.builder.MapperBuilderAssistant#buildResultMapping(java.lang.Class<?>, java.lang.String, java.lang.String, java.lang.Class<?>, org.apache.ibatis.type.JdbcType, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.Class<? extends org.apache.ibatis.type.TypeHandler<?>>, java.util.List<org.apache.ibatis.mapping.ResultFlag>, java.lang.String, java.lang.String, boolean)
3. org.apache.ibatis.builder.MapperBuilderAssistant#buildResultMapping(java.lang.Class<?>, java.lang.String, java.lang.String, java.lang.Class<?>, org.apache.ibatis.type.JdbcType, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.Class<? extends org.apache.ibatis.type.TypeHandler<?>>, java.util.List<org.apache.ibatis.mapping.ResultFlag>, java.lang.String, java.lang.String, boolean)
4. org.apache.ibatis.builder.BaseBuilder#resolveTypeHandler(java.lang.Class<?>, java.lang.Class<? extends org.apache.ibatis.type.TypeHandler<?>>)
5. org.apache.ibatis.type.TypeHandlerRegistry#getMappingTypeHandler
```

DEBUG 跟踪代码发现是 BaseBuilder 和 TypeHandlerRegistry 两个类做了调整

通过 Github 上 TypeHandlerRegistry 类的变更记录，发现是 [commit e92c2a2](https://github.com/mybatis/mybatis-3/commit/e92c2a2f1aacce52d7c1470b9aaa524dc8e9d1e7#diff-f54f4f9d0324952c3d7545a3e7a4dbee) 这次提交引入了这些变更。注释说明了这次变更的原因在 [issue #746](https://github.com/mybatis/old-google-code-issues/issues/746) 中有记录。为了解决 Spring 注入依赖的问题，有了这次的代码变更。

可以看到缓存 TypeHandler 的 Map 有了变化

```
-  private final Map<Class<?>, Map<Type, TypeHandler<?>>> REVERSE_TYPE_HANDLER_MAP = new HashMap<Class<?>, Map<Type, TypeHandler<?>>>();
+  private final Map<Class<?>, TypeHandler<?>> ALL_TYPE_HANDLERS_MAP = new HashMap<Class<?>, TypeHandler<?>>();
```

原来查找具体的 TypeHandler 是先根据 TypeHandler.class 类查找到 `Map<Type, TypeHandler<?>>`，最后通过属性的 javaType 查找到 TypeHandler。所以之前的代码和配置运行是没问题。但是之后改成了直接通过 TypeHandler.class 找 TypeHandler，所以 `<typeHandler handler="com...CodeEnumTypeHandler" javaType="com...ChangeSceneType" />` 之前枚举的 TypeHandler 配置都会被覆盖掉，会抛出 `No enum code 'MERCHANT'. class com...ChangeSceneType` 异常也就很好理解了。

## 解决问题

既然是直接通过 TypeHandler.class 找 TypeHandler，那么就可以对每种枚举都实现一个对应的 TypeHandler 类。这样带来的问题也很明显，项目中有多少枚举就得写多少对应的 TypeHandler。

```
public class MemberTypeHandler extends CodeEnumTypeHandler<MemberType> {
    public MemberTypeHandler(Class<MemberType> type) {
        super(type);
    }
}
```

通过在 Github Issue 里翻 enum 相关的信息，在 [Issue #995](https://github.com/mybatis/mybatis-3/issues/995) 找到了一个完美的解决办法。就是去掉 `<resultMap>` 配置中的typeHandler 属性。也就是说指定 typeHandler 是没有必要的，为什么是这样呢？

在设置返回对象的属性值时有如下的调用顺序：

```
1. org.apache.ibatis.executor.resultset.DefaultResultSetHandler#applyPropertyMappings
2. org.apache.ibatis.executor.resultset.DefaultResultSetHandler#getPropertyMappingValue
3. org.apache.ibatis.type.BaseTypeHandler#getResult(java.sql.ResultSet, java.lang.String)
4. com...CodeEnumTypeHandler#getNullableResult(java.sql.ResultSet, java.lang.String)
5. com...CodeEnumTypeHandler#valueOf
```

`org.apache.ibatis.executor.resultset.DefaultResultSetHandler#getPropertyMappingValue` 中有几行代码：

```
final TypeHandler<?> typeHandler = propertyMapping.getTypeHandler();
final String column = prependPrefix(propertyMapping.getColumn(), columnPrefix);
return typeHandler.getResult(rs, column);
```

通过 propertyMapping 找到了类型处理器，这个 propertyMapping 是通过遍历 `org.apache.ibatis.mapping.ResultMap` 的 `propertyResultMappings` 属性获得的。`ResultMap` 类对应于 Mapper 文件中的 `<resultMap>` 元素，`ResultMapping` 类对应于 `<resultMap>` 元素的子元素 `<result>`。

`ResultMap` 类中有四个 `ResultMapping` 列表，`ResultMap` 实例是由内部类 `ResultMap.Builder` 构造的，通过其`build` 方法可以看出 `idResultMappings`，`constructorResultMappings`，`propertyResultMappings` 是 `resultMappings` 的一个子集。`resultMappings` 又是什么时候构造出来的呢。

```
private List<ResultMapping> resultMappings;
private List<ResultMapping> idResultMappings;
private List<ResultMapping> constructorResultMappings;
private List<ResultMapping> propertyResultMappings;
```

`ResultMap` 构建的过程。

```
1. org.apache.ibatis.builder.xml.XMLMapperBuilder#resultMapElement(org.apache.ibatis.parsing.XNode, java.util.List<org.apache.ibatis.mapping.ResultMapping>)
2. org.apache.ibatis.builder.ResultMapResolver#resolve
3. org.apache.ibatis.builder.MapperBuilderAssistant#addResultMap
4. org.apache.ibatis.mapping.ResultMap.Builder#build
```

`ResultMapping` 也是由他的内部类`ResultMapping.Builder` 改造。它的构建的过程如下。

```
1. org.apache.ibatis.builder.xml.XMLMapperBuilder#resultMapElement(org.apache.ibatis.parsing.XNode, java.util.List<org.apache.ibatis.mapping.ResultMapping>)
2. org.apache.ibatis.builder.xml.XMLMapperBuilder#buildResultMappingFromContext
3. org.apache.ibatis.builder.MapperBuilderAssistant#buildResultMapping(java.lang.Class<?>, java.lang.String, java.lang.String, java.lang.Class<?>, org.apache.ibatis.type.JdbcType, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.Class<? extends org.apache.ibatis.type.TypeHandler<?>>, java.util.List<org.apache.ibatis.mapping.ResultFlag>, java.lang.String, java.lang.String, boolean)
4. org.apache.ibatis.mapping.ResultMapping.Builder#build
```

`buildResultMapping` 方法会调用前面提到的 `BaseBuilder#resolveTypeHandler` 方法，而因为我们没有配置 typeHandler 属性，所以此时调用 `BaseBuilder#resolveTypeHandler` 只会返回 null。但是每个类型都应该有它对应的类型处理器，这个类型处理器是什么时候构建出来的。`ResultMapping.Builder#build` 方法中就能找到答案了，这个方法会调用`ResultMapping.Builder#resolveTypeHandler`，如果它发现执行到这里 `ResultMapping` 的 `typeHandler` 属性还为 null，就会调用 `typeHandlerRegistry.getTypeHandler(resultMapping.javaType, resultMapping.jdbcType)`，这个方法和前面提到的同名方法是有区别的。它是从 `TYPE_HANDLER_MAP` 中取的 typeHandler，而前面是 `ALL_TYPE_HANDLERS_MAP`。`TYPE_HANDLER_MAP` 中存储的是属性的 javaType 和 jdbcType 与 typeHandler 映射的映射关系，可能有点拗口，也就是通过属性的 javaType 和 jdbcType 就可以找到它对应的类型处理器，而后者
`ALL_TYPE_HANDLERS_MAP` 存储的是 TypeHandler.class 和 TypeHandler 实例的映射关系。

总结一下，不必配置`<result>` 元素的 typeHandler 属性是因为这样避免了通过 typeHandler 属性值(在本例中就是之前的enumHandler)找对应的 TypeHandler 实例，而是通过 javaType 和 jdbcType (在本例终究是MemberType枚举和VARCHAR) 找到对应的 TypeHandler 实例。

最后一个问题。TypeHandlerRegistry 中存储的映射关系又是什么时候注册进来的呢。 从方法`org.apache.ibatis.builder.xml.XMLConfigBuilder#typeHandlerElement`里可以找到答案。
