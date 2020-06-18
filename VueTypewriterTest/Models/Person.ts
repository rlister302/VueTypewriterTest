
import { Dog, IDog } from "./Dog";
import Vue from 'vue';
import { Prop, Component } from 'vue-property-decorator'


export interface IPerson {
    
    firstName: string;
    
    lastName: string;
    
    doggy: Dog;
    
}


@Component({
    name: 'person-comp',
    template: '#person',
    components: {
        'dog-comp': Dog

    }
})
export class Person extends Vue implements IPerson {
    
    // FIRSTNAME
    @Prop({}) firstName: string;
    // LASTNAME
    @Prop({}) lastName: string;
    // DOGGY
    @Prop({}) doggy: Dog;
}
