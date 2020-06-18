"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Person = void 0;
var Dog_1 = require("./Dog");
var vue_1 = require("vue");
var vue_property_decorator_1 = require("vue-property-decorator");
var Person = /** @class */ (function (_super) {
    __extends(Person, _super);
    function Person() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    __decorate([
        vue_property_decorator_1.Prop({})
    ], Person.prototype, "firstName", void 0);
    __decorate([
        vue_property_decorator_1.Prop({})
    ], Person.prototype, "lastName", void 0);
    __decorate([
        vue_property_decorator_1.Prop({})
    ], Person.prototype, "doggy", void 0);
    Person = __decorate([
        vue_property_decorator_1.Component({
            name: 'person-comp',
            template: '#person',
            components: {
                'dog-comp': Dog_1.Dog
            }
        })
    ], Person);
    return Person;
}(vue_1.default));
exports.Person = Person;
//# sourceMappingURL=Person.js.map