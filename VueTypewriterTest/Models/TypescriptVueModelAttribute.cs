using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace VueTypewriterTest.Models
{
    public class TypescriptVueModelAttribute : Attribute
    {
        public Dictionary<string, string> ExternalTypes { get; private set; }

        public TypescriptVueModelAttribute() : base()
        {
            ExternalTypes = new Dictionary<string, string>();
        }

        public TypescriptVueModelAttribute(string[] externalTypes):base()
        {
            ExternalTypes = new Dictionary<string, string>();

            foreach (string s in externalTypes)
            {
                string t = s.Substring(s.LastIndexOf('.') + 1);
                ExternalTypes.Add(t, s);
            }
        }
    }
}
