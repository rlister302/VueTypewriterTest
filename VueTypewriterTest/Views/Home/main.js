"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vue_1 = require("vue");
var Dog_1 = require("../../Models/Dog");
var Person_1 = require("../../Models/Person");
var Container_1 = require("../../Models/Container");
new vue_1.default({
    el: '#app',
    components: {
        "person-comp": Person_1.Person,
        "dog-comp": Dog_1.Dog,
        "container-comp": Container_1.Container
    },
    methods: {
        parse: function (s) {
            console.log(s);
            //return JSON.parse(s);
            return s;
        }
    }
});
//# sourceMappingURL=main.js.map