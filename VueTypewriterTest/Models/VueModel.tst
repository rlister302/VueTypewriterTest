${
    using Typewriter.Extensions.Types;
    using System.Text;

    string LoudName(Property property)
    {
        return property.Name.ToUpperInvariant();
    }

    string GetComponentName(Class c) 
    {
        string compName = c.Name;

        string template = "{0}-comp";

        string camelClassName = ConvertClassNameToCamelCase(c.Name);


        return string.Format(template, camelClassName);
    }

    string GetTemplateId(Class c)
    {
        return ConvertClassNameToCamelCase(c.Name);
    }

    string ConvertClassNameToCamelCase(string c)
    {
        StringBuilder builder = new StringBuilder();

        if (c.Length < 1)
        {
            throw new ArgumentException("Length of string was 0");
        }

        builder.Append(c[0].ToString().ToLower());

        for (int i = 1; i < c.Length; i++)
        {
            builder.Append(c[i]);
        }

        return builder.ToString();
    }


    Attribute GetAttribute(Class c, string attrName)
    {
        Attribute attr = null;

        foreach (var a in c.Attributes) {
            if (a.Name == attrName)
            {
                attr = a;
                break;
            }
        }

        return attr;
    }
     

    string KnockoutType(Property p) {
        var typeName = string.Empty;

        if (p.Type.IsEnumerable)
        {
            if (p.Type.TypeArguments.Count == 1)
            {
                // Remove [] and change to observable array
                typeName = BuildTypeName(p.Type, (Class)p.Parent, false);
            }
            else {
                typeName = typeName = BuildTypeName(p.Type, (Class)p.Parent, false);
                var valueType = BuildTypeName(p.Type.TypeArguments[1], (Class)p.Parent, false).TrimEnd(new char[] {'[', ']'});
                valueType = $"KnockoutObservable<{valueType}>";

                typeName = typeName.Substring(0, typeName.LastIndexOf(":") + 1) + valueType + typeName.Substring(typeName.LastIndexOf(";"));
            }
        }
        else 
        {
            typeName = BuildTypeName(p.Type, (Class)p.Parent, false);
        }

        typeName = typeName.TrimEnd(new char[] {'[', ']'});

        return typeName;
    }

    string KnockoutValue(Property property) {
        var typeName = string.Empty;

        if (property.Type.IsEnumerable)
        {
            typeName = KnockoutType(property);

            if (property.Type.TypeArguments.Count < 2)
            {
                typeName = $"{property.Name} = ko.observableArray<{typeName}>([]);";
            }
            else
            {
                typeName = $"{property.Name} : {typeName} = {{}};";
            }
        }
        else 
        {
            typeName = BuildTypeName(property.Type, (Class)property.Parent, false);
            typeName = $"{property.Name} = ko.observable<{typeName}>();";
        }

        return typeName;
    }    

    bool IsPrimitive(Property p) {
        return p.Type.IsPrimitive || p.Type.IsEnum || p.Type.OriginalName.ToLower() == "object";
    }

    bool IsNotPrimitive(Property p) {
        return !IsPrimitive(p);
    }

    bool IsEntryPrimitive(Property p) {
        bool isPrimitive = IsPrimitive(p);

        if (p.Type.IsEnumerable)
        {
            // Just look at the first generic
            isPrimitive = p.Type.TypeArguments[0].IsPrimitive || p.Type.TypeArguments[0].IsEnum || p.Type.TypeArguments[0].OriginalName.ToLower() == "object";
        }

        return isPrimitive;
    }

    bool IsIgnoreSerialize(Class c)
    {
        bool ignore = false;

        var a = GetAttribute(c, "TypescriptIgnoreSerialize");
        if (a != null)
        {
            ignore = true;
        }
        else
        {
            if (c.Parent is Class && ((Class)c.Parent).Name.Contains("TSProxy"))
            {
                a = GetAttribute((Class)c.Parent, "TypescriptIgnoreSerialize");
                if (a != null)
                {
                    ignore = true;
                }
            }
        }

        return ignore;
    }

    bool IsPropertyIgnoreSerialize(Property p)
    {
        return IsIgnoreSerialize((Class)p.Parent);
    }

    bool IsEntryNotPrimitive(Property p) {
        return !IsEntryPrimitive(p);
    }

    string BuildBaseClass(Class c, bool isInterface)
    {
        var baseClass = string.Empty;

        var a = GetAttribute(c, "TypeScriptOverrideBase");

        if (a != null)
        {
            baseClass = isInterface ? "I" + a.Value : a.Value;
        }
        else if (c.BaseClass != null)
        {
            baseClass = BuildClassName(c.BaseClass, c, c.Namespace, isInterface);
        }

        return baseClass;
    }

    string BuildClassGenericParams(Class c, bool isInterface)
    {
        var generic = string.Empty;

        //generic = $" {c.TypeParameters.ToString()} ";
        generic = "<";

        for (int i = 0 ; i < c.TypeParameters.Count ; i++)
        {
            var a = c.TypeParameters[i];

            if (i != 0)
            {
                generic += ", ";
            }

            generic += a.Name;

            if (c.TypeArguments.Count > i && c.TypeArguments[i].Name != a.Name)
            {
                generic += " extends " + BuildTypeName(c.TypeArguments[i], c, isInterface);
            }
        }

        generic += ">";

        return generic;
    }

    string ClassNameWithExtends(Class c) {
        string generic = string.Empty;

        string extendClass = BuildBaseClass(c, false);
        if (!string.IsNullOrWhiteSpace(extendClass))
        {
            extendClass = " extends " + extendClass;
        }
        else if (!IsIgnoreSerialize(c)) {
            extendClass = "";
        }

        if (c.IsGeneric)
        {
            //generic = $" {c.TypeParameters.ToString()} ";
            generic = BuildClassGenericParams(c, false);
        }

        return c.Name + generic + extendClass;
    }

    string InterfaceNameWithExtends(Class c) {
        string genericTypeParams = string.Empty;

        string extendClass = BuildBaseClass(c, true);
        if (!string.IsNullOrWhiteSpace(extendClass))
        {
            extendClass = " extends " + extendClass;
        }

        if (c.IsGeneric)
        {
            //genericTypeParams = $"{c.TypeParameters.ToString()} ";
            genericTypeParams = BuildClassGenericParams(c, true);
        }
        return "I" + c.Name + genericTypeParams + extendClass;
    }

    string CallSuper(Class c) {
        string callSuper = string.Empty;

        if (c.BaseClass != null)
        {
            callSuper = "super(model);";
        }

        return callSuper;
    }

    string CallMap(Class c) {
        string s = string.Empty;
        if (c.BaseClass != null)
        {
            s += $"if (recursive)\r\n\t\t{{\r\n\t\t\tthis.mapI{c.BaseClass.Name}(model, true);\r\n\t\t}}";
        }

        return s;
    }

    string MapSet(Property p)
    {
        string s = string.Empty;

        if (p.Type.Name.ToLower() == "date")
        {
            s = $"if (model.{p.Name} != null && model.{p.Name}.toString().indexOf(\"/Date(\") >= 0) {{\n";
            s += $"\t\t\tthis.{p.Name}(new Date(parseInt(model.{p.Name}.toString().replace(\"/Date(\", \"\").replace(\")/\",\"\"), 10)));\n";
            s += "\t\t}\n\t\telse {\n";
            s += $"\t\t\tthis.{p.Name}(model.{p.Name});\n";
            s += "\t\t}";
        }
        else
        {
            s = $"this.{p.Name}(model.{p.Name});";
        }
        return s;
    }

    string CallPropertyMap(Property p) {
        return $"this.{p.Name}.mapI{p.Type.Name}(model.{p.Name}, recursive);";
    }

    string InterfacePropertyType(Property p) {
        var t = BuildTypeName(p.Type, (Class)p.Parent, true);

        return t;
    }

    string BuildGenericParameters(string originalName, Class c, TypeCollection types, bool isInterface)
    {
        string typeName = string.Empty;

        if (originalName != "List")
        {
            typeName += "<";
        }

        for (int i = 0 ; i < types.Count ; i++)
        {
            if (i != 0) 
            {
                typeName += ", ";
            }

            typeName += BuildTypeName(types[i], c, isInterface);
        }

        if (originalName != "List")
        {
            typeName += ">";
        }

        return typeName;
    }

    string BuildTypeName(Type t, Class c, bool isInterface)
    {
        string typeName = t.Name;
        bool isGenericParameterType = false;

        foreach (var p in c.TypeParameters)
        {
            if (t.OriginalName == p.Name)
            {
                isGenericParameterType = true;
                break;
            }
        }

        if ((!(t.IsPrimitive || t.OriginalName.ToLower() == "object") || t.IsEnum) && !isGenericParameterType)
        {
            // If enumerable type turn it into an array
            if (t.OriginalName != "List")
            {
                Type ty = (t.IsEnumerable && t.TypeArguments.Count > 0) ? t.TypeArguments[0] : t;

                string iface = (isInterface && !ty.IsEnum) ? "I" : "";
                string contClass = ty.ContainingClass != null ? iface + ty.ContainingClass.Name + "." : string.Empty;
                string nameSpace = (ty.ContainingClass != null && ty.ContainingClass.FullName == c.FullName) ? "" : "";
                string originalName = ty.OriginalName;

                typeName = nameSpace + contClass + iface + originalName;
            }
            else 
            {
                typeName = string.Empty;
            }

            if (t.IsGeneric)
            {
                typeName += BuildGenericParameters(t.OriginalName, c, t.TypeArguments, isInterface);
            }

        }

        if (t.IsEnumerable)
        {
            typeName = typeName.TrimEnd(new char[] {'[', ']'});
            typeName += "[]";
        }

        typeName = typeName.TrimEnd(new char[] {'?'});
            
        return typeName;
    }

    string BuildClassName(Class c, Class derivedClass, string currentNamespace, bool isInterface)
    {
        var iface = (isInterface) ? "I" : "";
        string classname = iface + c.Name;
        string nameSpace = "";
        string gen = string.Empty;

        if (c.IsGeneric)
        {
            //gen = BuildGenericParameters(c.Name, c, c.TypeArguments, isInterface);
            gen = "<";

            if (derivedClass != null && derivedClass.TypeParameters.Count > 0)
            {
                for (int i = 0 ; i < c.TypeParameters.Count ; i++)
                {
                    var p = c.TypeParameters[i];

                    if (i != 0)
                    {
                        gen += ", ";
                    }

                    gen += p.Name;
                }
                
                gen += ">";
            }
            else
            {
                gen = BuildGenericParameters(c.Name, c, c.TypeArguments, isInterface);
            }

        }

        return nameSpace + classname + gen;
    }

    string FullPropertyClass(Property p) {
       return BuildTypeName(p.Type, (Class)p.Parent, false);
    }

    bool IsGenericType(Property p) {
        Typewriter.CodeModel.Class cl = (Typewriter.CodeModel.Class)p.Parent;
        var ret = false;
        if (cl.IsGeneric) {
            foreach (var param in cl.TypeParameters) {
                if (param.Name == p.Type.Name) {
                    ret = true;
                    break;
                }
            }
        }
        return ret;
    }
    
    bool IsClassIgnored(Class c)
    {
        bool ignored = false;
        var a = GetAttribute(c, "TypeScriptIgnore");

        if (a != null)
        {
            ignored = true;
        }

        return ignored;
    }

    bool IsPropertyIgnored(Property p) {
        bool ignored = false;
        
        foreach(var a in p.Attributes){
            if(a.Name == "TypeScriptIgnore" || a.Name == "JsonIgnore"){
                ignored = true;
                break;
            }
        }

        if (!ignored)
        {
            // If JustPrimitive Attribute on Class then ony include Primitive Type properties.
            var c = (Class)p.Parent;

            if (c.Parent is Class && ((Class)c.Parent).Name.Contains("TSProxy"))
            {
                c = (Class)c.Parent;
            }

            foreach(var a in c.Attributes)
            {
                if(a.Name == "TypescriptJustPrimitive")
                {
                    if (!(p.Type.IsPrimitive || p.Type.OriginalName.ToLower() == "object") || p.Type.IsGeneric)
                    {
                        ignored = true;
                    }
                    break;
                }
            }
        }

        return ignored;
    }

    HashSet<string> GetClassNames(Class c, bool isInterface)
    {
        HashSet<string> classes = new HashSet<string>();

        if (c != null)
        {
            classes.Add((isInterface) ? "I" + c.Name : c.Name);
        }

        return classes;
    }

    void ImportType(Type t, Class c, Dictionary<string, string> imports)
    {
        bool isGenericParameterType = false;

        foreach (var p in c.TypeParameters)
        {
            if (t.OriginalName == p.Name)
            {
                isGenericParameterType = true;
                break;
            }
        }

        if ((!(t.IsPrimitive || t.OriginalName.ToLower() == "object") || t.IsEnum) && !isGenericParameterType)
        {
            Type ty = (t.IsEnumerable) ? t.TypeArguments[0] : t;
            if (ty.ContainingClass != null)
            {
                var fullName = c.ContainingClass == null ? c.FullName : c.ContainingClass.FullName;

                if (ty.ContainingClass.FullName != fullName)
                {
                    imports[ty.ContainingClass.Name] = ty.ContainingClass.Namespace;
                }
            }
            else
            {                
                imports[ty.OriginalName] = ty.Namespace;
            }

            if (t.IsGeneric)
            {
                //typeName += BuildGenericParameters(t.OriginalName, c, t.TypeArguments, isInterface);
            }
        }
    }

    void ImportClass(Class c, Class derivedClass, Dictionary<string, string> imports)
    {
        imports[c.Name] = c.Namespace;

        if (c.IsGeneric)
        {
            if (derivedClass == null || derivedClass.TypeParameters.Count == 0)
            {
                foreach (var p in c.TypeArguments)
                {
                    ImportType(p, c, imports);
                }
            }
        }
    }

    void ProcessClassImports(Class c, Dictionary<string, string> imports)
    {
        var at = GetAttribute(c, "TypeScriptOverrideBase");

        if (at != null)
        {
            imports[at.Value] = c.BaseClass.Namespace;
        }
        
        if (c.BaseClass != null)
        {
            ImportClass(c.BaseClass, c, imports);
        }

        for (int i = 0 ; i < c.TypeParameters.Count ; i++)
        {
            var a = c.TypeParameters[i];

            if (c.TypeArguments.Count > i && c.TypeArguments[i].Name != a.Name)
            {
                ImportType(c.TypeArguments[i], c, imports);
            }
        }
        
        foreach (var p in c.Properties)
        {
            if (!IsPropertyIgnored(p))
            {
                ImportType(p.Type, c, imports);
            }
        }

        foreach (var nc in c.NestedClasses)
        {
            if (!IsClassIgnored(nc))
            {
                ProcessClassImports(nc, imports);
            }
        }
    }

    string Imports(Class c)
    {
        Dictionary<string, string> imports = new Dictionary<string, string>();

        ProcessClassImports(c, imports);

        string iString = $"";
        //imports["KeyValuePair"] = "System.Collections.Generic";

        foreach (var i in imports)
        {
            // Simplified for this example
            string path = $"./";
            string exports = $"{i.Key}, I{i.Key}";
            string module = i.Key;

            iString += $"import {{ {exports} }} from \"{path}{module}\";\r\n";
        }

        iString += "import Vue from 'vue';\n";
        iString += "import { Prop, Component } from 'vue-property-decorator'";

        return iString;
    }

    string ProcessDependentComponents(Class c)
    {
        Dictionary<string, string> imports = new Dictionary<string, string>();

        ProcessClassImports(c, imports);
        string returnVal = $"";

        foreach (var import in imports) 
        {
            string start = ConvertClassNameToCamelCase(import.Key);
            string format = "'{0}-comp': {1}";
            returnVal += string.Format(format, start, import.Key);
            returnVal += "\r\n";
        
        }

        return returnVal;
    }

    bool IncludeExportModule(Class c)
    {
        return (c.NestedClasses.Count > 0) || c.NestedEnums.Count > 0;
    }

    string ConstructorType(Class c)
    {   
        string iface = "I";

        string typeName = iface + c.Name;   
        if (c.IsGeneric)
        {
            typeName += BuildGenericParameters(c.Name, c, c.TypeArguments, true);
        }


        return typeName;
    }

    string InitializeEnumerable(Property p)
    {
        var knockoutType = KnockoutType(p);

        string code = $"\t\tif (model.{p.Name} != null) {{\r\n";

        if (p.Type.TypeArguments.Count > 1)
        {
            var t = BuildTypeName(p.Type.TypeArguments[1], (Class)p.Parent, false);

            code += $"\t\t\tvar _{p.Name}List_: {knockoutType} = {{}};\r\n";
            code += $"\t\t\tObject.keys(model.{p.Name}).forEach(k => {{\r\n";
            code += $"\t\t\t\t_{p.Name}List_[k] = ko.observable<{t}>(model.{p.Name}[k]);\r\n";
            code += $"\t\t\t}});\r\n";
            code += $"\t\t\tthis.{p.Name} = _{p.Name}List_;\r\n";
        }
        else
        {
            code += $"\t\t\tvar _{p.Name}List_: Array<{knockoutType}> = new Array<{knockoutType}>();\r\n";
            code += $"\t\t\tfor (let entry of model.{p.Name}) {{\r\n";
            if (IsEntryPrimitive(p)) 
            {
                code += $"\t\t\t\t_{p.Name}List_.push(entry);\r\n";
            }
            else {
                code += $"\t\t\t\t_{p.Name}List_.push(new {knockoutType}(entry));\r\n";
            }
            code += $"\t\t\t}}\r\n";
            code += $"\t\t\tthis.{p.Name}.removeAll();\r\n";
            code += $"\t\t\tko.utils.arrayPushAll<{knockoutType}>(this.{p.Name}, _{p.Name}List_);\r\n";
        }

        code += $"\t\t}}";

        return code;
    }

    string CallPropertyUnMap(Property p) {
        var t = BuildTypeName(p.Type, (Class)p.Parent, true);

        var code = $"model.{p.Name} = <{t}>{{}};\r\n";
        code += $"\t\t\tthis.{p.Name}.unmapI{p.Type.Name}(model.{p.Name});";

        return code;
    }

    string CallUnMap(Class c) {
        string s = string.Empty;
        if (c.BaseClass != null)
        {
            s += $"this.unmapI{c.BaseClass.Name}(model);";
        }

        return s;
    }

    string UnMapSet(Property p)
    {
        string s = string.Empty;
        s = $"model.{p.Name} = this.{p.Name}();";
        return s;
    }

    string UnInitializeEnumerable(Property p)
    {
        var knockoutType = KnockoutType(p);

        string code = $"\t\tif (this.{p.Name} != null) {{\r\n";

        if (p.Type.TypeArguments.Count > 1)
        {
            //var t = BuildTypeName(p.Type.TypeArguments[1], (Class)p.Parent, false);
            var t = BuildTypeName(p.Type, (Class)p.Parent, true);

            code += $"\t\t\tmodel.{p.Name} = <{t}>{{}};\r\n";
            code += $"\t\t\tObject.keys(this.{p.Name}).forEach(k => {{\r\n";
            code += $"\t\t\t\tmodel.{p.Name}[k] = this.{p.Name}[k]();\r\n";
            code += $"\t\t\t}});\r\n";
        }
        else
        {
            var t = BuildTypeName(p.Type, (Class)p.Parent, true).TrimEnd(new char[] {'[', ']'});
            var last = t.IndexOf("<");
            var tEnd = last >= 0 ? t.Substring(0, last): t;
            last = tEnd.LastIndexOf(".");
            tEnd = last >= 0 ? tEnd.Substring(last+1) : tEnd;
            
            code += $"\t\t\tmodel.{p.Name} = new Array<{t}>();\r\n";
            code += $"\t\t\tfor (let entry of this.{p.Name}()) {{\r\n";
            if (IsEntryPrimitive(p)) 
            {
                code += $"\t\t\t\tmodel.{p.Name}.push(entry);\r\n";
            }
            else {
                code += $"\t\t\t\tvar _e{p.Name} : {t} = <{t}>{{}};\r\n";
                code += $"\t\t\t\tentry.unmap{tEnd}(_e{p.Name});\r\n";

                code += $"\t\t\t\tmodel.{p.Name}.push(_e{p.Name});\r\n";
            }
            code += $"\t\t\t}}\r\n";
        }

        code += $"\t\t}}";

        return code;
    }
}
$Classes([TypescriptVueModel])[$Imports


export interface I$Name {
    $Properties[
    $name: $Type;
    ]
}


@Component({
    name: '$GetComponentName',
    template: '#$GetTemplateId',
    components: {
        $ProcessDependentComponents
    }
})
export class $Name extends Vue implements I$Name {
    $Properties[
    // $LoudName
    @Prop({}) $name: $Type;]
}]
