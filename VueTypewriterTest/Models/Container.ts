
import { Person, IPerson } from "./Person";
import Vue from 'vue';
import { Prop, Component } from 'vue-property-decorator'


export interface IContainer {
    
    person: Person;
    
}


@Component({
    name: 'container-comp',
    template: '#container',
    components: {
        'person-comp': Person

    }
})
export class Container extends Vue implements IContainer {
    
    // PERSON
    @Prop({}) person: Person;
}
