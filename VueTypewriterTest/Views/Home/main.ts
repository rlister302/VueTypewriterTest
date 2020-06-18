import Vue from 'vue';

import { Dog } from '../../Models/Dog';
import { Person } from '../../Models/Person';
import { Container } from '../../Models/Container';

new Vue({
    el: '#app',
    components: {
        "person-comp": Person,
        "dog-comp": Dog,
        
        "container-comp": Container


    },
    methods: {
        parse(s) {
            console.log(s);
            //return JSON.parse(s);
            return s;
        }
    }
})