using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace VueTypewriterTest.Models
{
    [TypescriptVueModel]
    public class Dog 
    {
        public string Name { get; set; }
        public string Breed { get; set; }
    }
}
