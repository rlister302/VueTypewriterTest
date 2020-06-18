
import Vue from 'vue';
import { Prop, Component } from 'vue-property-decorator'


export interface IDog {
    
    name: string;
    
    breed: string;
    
}


@Component({
    name: 'dog-comp',
    template: '#dog',
    components: {
        
    }
})
export class Dog extends Vue implements IDog {
    
    // NAME
    @Prop({}) name: string;
    // BREED
    @Prop({}) breed: string;
}
