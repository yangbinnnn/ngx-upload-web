-- ignore *.html files
if ngx.var.uri:match(".html$") then
    return "</body>"
end

local inject_div = [[
<div id="upload-inject">
<link rel="stylesheet" href="https://unpkg.com/iview@2.14.3/dist/styles/iview.css">
<script src="https://unpkg.com/vue@2.5.16/dist/vue.min.js"></script>
<script src="https://unpkg.com/iview@2.14.3/dist/iview.min.js"></script>
<style>a {color: -webkit-link}</style>
<div id="app-upload">
<upload
    multiple
    type="drag"
    :action="uploadUrl"
    :before-upload="beforeUpload">
    <div style="padding: 20px 0">
	<icon type="ios-cloud-upload" size="52" style="color: #3399ff"></icon>
	<p>点击或拖拽文件上传</p>
    </div>
</upload>
</div>
<script>
new Vue({
    el: '#app-upload',
    data: {
	uploadUrl: ''
    },
    mounted() {
	this.uploadApi = '/_upload'
    },
    methods: {
	beforeUpload: function() {
	    this.uploadUrl = this.uploadApi + window.location.pathname
	    let promise = new Promise((resolve) => {
		this.$nextTick(function () {
		    resolve(true);
		})
	    })
	    return promise
	}
    }
})
</script>
<div>
</body>
]]

return inject_div

