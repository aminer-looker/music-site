var jade = jade || require('jade/lib/runtime');

this["JST"] = this["JST"] || {};

this["JST"]["composer_list_item"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<a href=\"{{composer.getDetailUrl()}}\">{{composer.first_name}} {{composer.last_name}}</a>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}