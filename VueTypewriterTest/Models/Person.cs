using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace VueTypewriterTest.Models
{
    [TypescriptVueModel]
    public class Person
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public Dog Doggy { get; set; }
    }
}
