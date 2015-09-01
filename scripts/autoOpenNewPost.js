var spawn = require('child_process').spawn;

hexo.on('new', function(post){
	spawn('gvim', ['-f',post.path]);
});
