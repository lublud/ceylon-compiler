
import ceylon.language.metamodel{
    type, 
    annotations, optionalAnnotation, sequencedAnnotations,
    Annotation2 = Annotation, 
    ConstrainedAnnotation, OptionalAnnotation, SequencedAnnotation, 
    Annotated,
    ClassOrInterface, Class, Interface,
    Function, Attribute
}
import ceylon.language.metamodel.declaration {
    AttributeDeclaration,
    VariableDeclaration,
    TopLevelOrMemberDeclaration,
    FunctionDeclaration,
    ClassDeclaration,
    ClassOrInterfaceDeclaration,
    InterfaceDeclaration,
    Package
}

Package aPackage {
    value aClassType = type(AClass(""));
    value aClassDecl = aClassType.declaration;
    value pkg = aClassDecl.packageContainer;
    return pkg;
}
AttributeDeclaration aToplevelAttributeDecl {
    assert(is AttributeDeclaration result = aPackage.getAttribute("aToplevelAttribute"));
    return result;
}
VariableDeclaration aToplevelGetterSetterDecl {
    assert(is VariableDeclaration result = aPackage.getAttribute("aToplevelGetterSetter"));
    return result;
}
FunctionDeclaration aToplevelFunctionDecl {
    assert(is FunctionDeclaration result = aPackage.getFunction("aToplevelFunction"));
    return result;
}
ClassDeclaration aClassDecl {
    return type(AClass("")).declaration;
}
ClassDeclaration aAbstractClassDecl {
    assert(exists sup=aClassDecl.superclass);
    return sup.declaration;
}
InterfaceDeclaration aInterfaceDecl {
    assert(exists sup=aClassDecl.superclass);
    assert(exists iface0=sup.interfaces[0]);
    return iface0.declaration;
}
ClassDeclaration memberClassDecl(ClassOrInterfaceDeclaration outerClass, String memberName) {
    for (ClassDeclaration cDecl in outerClass.members<ClassDeclaration>()) {
        if (cDecl.name == memberName) {
            return cDecl;
        }
    } 
    throw;
}
InterfaceDeclaration memberInterfaceDecl(ClassOrInterfaceDeclaration outerClass, String memberName) {
    for (InterfaceDeclaration iDecl in outerClass.members<InterfaceDeclaration>()) {
        if (iDecl.name == memberName) {
            return iDecl;
        }
    } 
    throw;
}

ClassOrInterface<T> annotationType<T>(T t) {
    return type(t);
}

ClassOrInterface<Shared> sharedAnnotation = annotationType(Shared());
ClassOrInterface<Abstract> abstractAnnotation = annotationType(Abstract());
ClassOrInterface<Formal> formalAnnotation = annotationType(Formal());
ClassOrInterface<Default> defaultAnnotation = annotationType(Default());
ClassOrInterface<Actual> actualAnnotation = annotationType(Actual());
ClassOrInterface<Variable> variableAnnotation = annotationType(Variable());
ClassOrInterface<Doc> docAnnotation = annotationType(Doc(""));
ClassOrInterface<Seq> seqAnnotation = annotationType(Seq(""));
ClassOrInterface<Deprecation> deprecatedAnnotation = annotationType(Deprecation(""));
ClassOrInterface<Optional> optAnnotation = annotationType(Optional());

void checkAToplevelAttributeAnnotations() {
    //shared
    assert(annotations(sharedAnnotation, aToplevelAttributeDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aToplevelAttributeDecl) exists);
    assert(aToplevelAttributeDecl.annotations<Shared>().size == 1);
    // doc
    assert(exists doc = annotations(docAnnotation, aToplevelAttributeDecl), 
        doc.description == "aToplevelAttribute");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aToplevelAttributeDecl), 
        doc2.description == "aToplevelAttribute");
    assert(nonempty doc3 = aToplevelAttributeDecl.annotations<Doc>(),
        doc3.first.description == "aToplevelAttribute");
    // seq
    variable value seqs = annotations(seqAnnotation, aToplevelAttributeDecl);
    assert(seqs.size == 2);
    assert(exists seq = seqs[0], seq.seq == "aToplevelAttribute 1");
    assert(exists seq2 = seqs[1], seq2.seq == "aToplevelAttribute 2");
    assert(sequencedAnnotations(seqAnnotation, aToplevelAttributeDecl).size == 2);
    assert(aToplevelAttributeDecl.annotations<Seq>().size == 2);
    
    // Using funky type arguments to Declaration.annotations<>()
    assert(aToplevelAttributeDecl.annotations<Nothing>().empty);
    // TODO Depends on fix for #1157 assert(aToplevelAttributeDecl.annotations<ConstrainedAnnotation<Nothing, Anything, AttributeDeclaration>>() empty);
    assert(nonempty doc4 = aToplevelAttributeDecl.annotations<ConstrainedAnnotation<Doc, Anything, AttributeDeclaration>>(),
        is Doc doc4_1 = doc4.first,
        doc4_1.description == "aToplevelAttribute");
    assert(nonempty doc5 = aToplevelAttributeDecl.annotations<OptionalAnnotation<Doc, AttributeDeclaration>>(),
        is Doc doc5_1 = doc5.first,
        doc5_1.description == "aToplevelAttribute");
    assert(aToplevelAttributeDecl.annotations<Shared|Doc|Seq>().size == 4);
    assert(aToplevelAttributeDecl.annotations<Shared|Doc>().size == 2);
    assert(aToplevelAttributeDecl.annotations<Doc|Seq>().size == 3);
    
    // since Doc is not Sequenced, this returns empty:
    assert(nonempty shared6 = aToplevelAttributeDecl.annotations<OptionalAnnotation<Shared, AttributeDeclaration>>(),
        is Shared shared6_1 = shared6.first);
    assert(nonempty seq7 = aToplevelAttributeDecl.annotations<SequencedAnnotation<Seq, AttributeDeclaration>>(),
        is Seq seq7_1 = seq7.first,
        seq7_1.seq == "aToplevelAttribute 1");
}

void checkAToplevelGetterSetterAnnotations() {
    //shared
    assert(annotations(sharedAnnotation, aToplevelGetterSetterDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aToplevelGetterSetterDecl) exists);
    assert(aToplevelGetterSetterDecl.annotations<Shared>() nonempty);
    // doc
    assert(exists doc = annotations(docAnnotation, aToplevelGetterSetterDecl), 
        doc.description == "aToplevelGetter");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aToplevelGetterSetterDecl), 
        doc2.description == "aToplevelGetter");
    assert(nonempty doc3 = aToplevelGetterSetterDecl.annotations<Doc>(),
        doc3.first.description == "aToplevelGetter");
    // seq
    variable value seqs = annotations(seqAnnotation, aToplevelGetterSetterDecl);
    assert(seqs.size == 1);
    assert(exists seq = seqs[0], seq.seq == "aToplevelGetter 1");
    assert(sequencedAnnotations(seqAnnotation, aToplevelGetterSetterDecl).size == 1);
    assert(nonempty seq2 = aToplevelGetterSetterDecl.annotations<Seq>(),
        seq2.first.seq == "aToplevelGetter 1");
    
    // setter
    assert(exists docsetter = optionalAnnotation(docAnnotation, aToplevelGetterSetterDecl.setter), 
        docsetter.description == "aToplevelSetter");
}

void checkAToplevelFunctionAnnotations() {
    //shared
    assert(annotations(sharedAnnotation, aToplevelFunctionDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aToplevelFunctionDecl) exists);
    assert(aToplevelFunctionDecl.annotations<Shared>() nonempty);
    // doc
    assert(exists doc = annotations(docAnnotation, aToplevelFunctionDecl), 
            doc.description == "aToplevelFunction");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aToplevelFunctionDecl), 
            doc2.description == "aToplevelFunction");
    assert(nonempty doc3=aToplevelFunctionDecl.annotations<Doc>(),
            doc3.first.description == "aToplevelFunction");
    // seq
    variable value seqs = annotations(seqAnnotation, aToplevelFunctionDecl);
    assert(seqs.size == 1);
    assert(exists seq = seqs[0], 
            seq.seq == "aToplevelFunction 1");
    assert(sequencedAnnotations(seqAnnotation, aToplevelFunctionDecl).size == 1);
    assert(nonempty seq2=aToplevelFunctionDecl.annotations<Seq>(),
            seq2.first.seq == "aToplevelFunction 1");
    
    // parameter
    assert(exists parameter = aToplevelFunctionDecl.parameters[0]);
    // parameter doc
    assert(exists pdoc = annotations(docAnnotation, parameter),
            pdoc.description == "aToplevelFunction.parameter");
    // parameter seq
    value pseqs = annotations(seqAnnotation, parameter);
    assert(pseqs.size == 1);
    assert(exists pseq = pseqs[0],
            pseq.seq== "aToplevelFunction.parameter 1");
}

/*TODO test object declarations!
void checkAToplevelObjectAnnotations() {
    value aToplevelObjectDecl = type(aToplevelObject).declaration;
    //shared
    assert(annotations(sharedAnnotation, aToplevelObjectDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aToplevelObjectDecl) exists);
    assert(aToplevelObjectDecl.annotations<Shared>() nonempty);
    
    // doc
    assert(exists doc = annotations(docAnnotation, aToplevelObjectDecl), 
        doc.description == "aToplevelObject");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aToplevelObjectDecl), 
        doc2.description == "aToplevelObject");
    assert(nonempty doc3 = aToplevelObjectDecl.annotations<Doc>(),
        doc3.first.description == "aToplevelObject");
    // seq
    variable value seqs = annotations(seqAnnotation, aToplevelObjectDecl);
    assert(seqs.size == 1);
    assert(exists seq = seqs[0], seq.seq == "aToplevelObject 1");
    assert(sequencedAnnotations(seqAnnotation, aToplevelObjectDecl).size == 1);
    assert(nonempty seq2 = aToplevelObjectDecl.annotations<Seq>(),
        seq2.first.seq == "aToplevelObject 1");
}*/

void checkAClass() {
    //shared
    assert(annotations(sharedAnnotation, aClassDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aClassDecl) exists);
    assert(aClassDecl.annotations<Shared>() nonempty);
    //abstract
    assert(! annotations(abstractAnnotation, aClassDecl) exists);
    assert(! optionalAnnotation(abstractAnnotation, aClassDecl) exists);
    assert(! aClassDecl.annotations<Abstract>() nonempty);
    // doc
    assert(exists doc = annotations(docAnnotation, aClassDecl), 
        doc.description == "AClass");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aClassDecl), 
        doc2.description == "AClass");
    assert(nonempty doc3 = aClassDecl.annotations<Doc>(),
        doc3.first.description == "AClass");
    // seq
    variable value seqs = annotations(seqAnnotation, aClassDecl);
    assert(seqs.size == 2);
    assert(exists seq = seqs[0], seq.seq == "AClass 1");
    assert(exists seq2 = seqs[1], seq2.seq == "AClass 2");
    assert(sequencedAnnotations(seqAnnotation, aClassDecl).size == 2);
    assert(nonempty seq3 = aClassDecl.annotations<Seq>(),
        seq3.size == 2,
        seq3.first.seq == "AClass 1");
    
    // parameter
    assert(exists parameter = aClassDecl.parameters[0]);
    // parameter doc
    assert(exists pdoc = annotations(docAnnotation, parameter),
            pdoc.description == "AClass.parameter");
    // parameter seq
    value pseqs = annotations(seqAnnotation, parameter);
    assert(pseqs.size == 2);
    assert(exists pseq = pseqs[0],
            pseq.seq== "AClass.parameter 1");
    assert(exists pseq2 = pseqs[1],
            pseq2.seq== "AClass.parameter 2");
}

void checkAAbstractClass() {
    //shared
    assert(annotations(sharedAnnotation, aAbstractClassDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aAbstractClassDecl) exists);
    //abstract
    assert(annotations(abstractAnnotation, aAbstractClassDecl) exists);
    assert(optionalAnnotation(abstractAnnotation, aAbstractClassDecl) exists);
    // doc
    assert(exists doc = annotations(docAnnotation, aAbstractClassDecl), 
        doc.description == "AAbstractClass");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aAbstractClassDecl), 
        doc2.description == "AAbstractClass");
    // seq
    variable value seqs = annotations(seqAnnotation, aAbstractClassDecl);
    assert(seqs.size == 2);
    assert(exists seq = seqs[0], seq.seq == "AAbstractClass 1");
    assert(exists seq2 = seqs[1], seq2.seq == "AAbstractClass 2");
    assert(sequencedAnnotations(seqAnnotation, aAbstractClassDecl).size == 2);
    
    // parameter
    assert(exists parameter = aAbstractClassDecl.parameters[0]);
    // parameter doc
    assert(exists pdoc = annotations(docAnnotation, parameter),
            pdoc.description == "AAbstractClass.parameter");
    // parameter seq
    value pseqs = annotations(seqAnnotation, parameter);
    assert(pseqs.size == 0);
    
    // Members of abstract class
    // formalAttribute
    assert(exists fam=aAbstractClassDecl.apply().getAttribute<AAbstractClass, Attribute<String>>("formalAttribute"));
    assert(is VariableDeclaration fa=fam(AClass("")).declaration);
    assert(annotations(sharedAnnotation, fa) exists);
    assert(annotations(actualAnnotation, fa) exists);
    assert(exists fadoc = annotations(docAnnotation, fa),
            fadoc.description == "AAbstractClass.formalAttributeGetter");
    assert(exists fasdoc = annotations(docAnnotation, fa.setter),
            fasdoc.description == "AAbstractClass.formalAttributeSetter");
    
    // formalMethod
    assert(exists fmm=aAbstractClassDecl.apply().getFunction<AAbstractClass, Function<Anything, [String]>>("formalMethod"));
    value fm=fmm(AClass("")).declaration;
    // shared
    assert(annotations(sharedAnnotation, fm) exists);
    // actual
    assert(annotations(actualAnnotation, fm) exists);
    // default
    assert(annotations(defaultAnnotation, fm) exists);
    // doc
    assert(exists fmdoc = annotations(docAnnotation, fm),
            fmdoc.description == "AAbstractClass.formalMethod");
    // parameter
    assert(exists fmp = fm.parameters[0]);
    // parameter doc
    assert(exists fmpdoc = annotations(docAnnotation, fmp),
            fmpdoc.description == "AAbstractClass.formalMethod.parameter");
    
    // InnerClass
    assert(exists icm=aAbstractClassDecl.apply().getClassOrInterface<AAbstractClass, Class<AAbstractClass.InnerClass, [String]>>("InnerClass"));
    value ic=icm(AClass("")).declaration;
    // shared
    assert(annotations(sharedAnnotation, ic) exists);
    // shared
    assert(exists icdoc = annotations(docAnnotation, ic));
    assert(icdoc.description == "AAbstractClass.InnerClass");
    // InnerClass parameter
    assert(exists icparameter = ic.parameters[0]);
    // InnerClass parameter doc
    assert(exists icpdoc = annotations(docAnnotation, icparameter),
            icpdoc.description == "AAbstractClass.InnerClass.parameter");
    // TODO inner classes methods
    
    // InnerInterface
    assert(exists iim=aAbstractClassDecl.apply().getClassOrInterface<AAbstractClass, Interface<AAbstractClass.InnerInterface>>("InnerInterface"));
    value ii=iim(AClass("")).declaration;
    // shared
    assert(annotations(sharedAnnotation, ii) exists);
    // shared
    assert(exists iidoc = annotations(docAnnotation, ii));
    assert(iidoc.description == "AAbstractClass.InnerInterface");
    // TODO inner interfaces methods
    
    
    // TODO Object members
}

void checkAInterface() {
    assert(is Interface<AInterface> iface = aInterfaceDecl.apply());
    //shared
    assert(annotations(sharedAnnotation, aInterfaceDecl) exists);
    assert(optionalAnnotation(sharedAnnotation, aInterfaceDecl) exists);
    //abstract
    //assert(! annotations(abstractAnnotation, aInterfaceDecl.declaration) exists);
    //assert(! optionalAnnotation(abstractAnnotation, aInterfaceDecl.declaration) exists);
    // doc
    assert(exists doc = annotations(docAnnotation, aInterfaceDecl), 
            doc.description == "AInterface");
    assert(exists doc2 = optionalAnnotation(docAnnotation, aInterfaceDecl), 
            doc2.description == "AInterface");
    // seq
    variable value seqs = annotations(seqAnnotation, aInterfaceDecl);
    assert(seqs.size == 2);
    assert(exists seq = seqs[0], 
            seq.seq == "AInterface 1");
    assert(exists seq2 = seqs[1], 
            seq2.seq == "AInterface 2");
    assert(sequencedAnnotations(seqAnnotation, aInterfaceDecl).size == 2);
    
    // Members of interface
    // formalAttribute
    assert(exists fam=iface.getAttribute<AInterface, Attribute<String>>("formalAttribute"));
    value fa = fam(AClass("")).declaration;
    assert(annotations(sharedAnnotation, fa) exists);
    assert(exists fadoc = annotations(docAnnotation, fa),
            fadoc.description == "AInterface.formalAttribute");
    
    // defaultGetterSetter
    assert(exists dgsm=iface.getAttribute<AInterface, Attribute<String>>("defaultGetterSetter"));
    assert(is VariableDeclaration dgs = dgsm(AClass("")).declaration);
    assert(annotations(sharedAnnotation, dgs) exists);
    assert(annotations(defaultAnnotation, dgs) exists);
    assert(exists dgdoc = annotations(docAnnotation, dgs),
            dgdoc.description == "AInterface.defaultGetter");
    assert(exists dsdoc = annotations(docAnnotation, dgs.setter),
            dsdoc.description == "AInterface.defaultSetter");
    
    // getterSetter
    assert(exists gsm=iface.getAttribute<AInterface, Attribute<String>>("getterSetter"));
    assert(is VariableDeclaration gs = gsm(AClass("")).declaration);
    assert(annotations(sharedAnnotation, gs) exists);
    assert(exists gsdoc = annotations(docAnnotation, gs),
            gsdoc.description == "AInterface.getter");
    // setter annotations
    assert(exists gssdoc = annotations(docAnnotation, gs.setter),
            gssdoc.description == "AInterface.setter");
    
    // TODO nonsharedGetterSetter
    //assert(exists ngsm=iface.getAttribute<AInterface, Attribute<String>>("nonsharedGetterSetter"));
    //value ngs=ngsm(AClass(""));
    //assert(annotations(sharedAnnotation, ngs) exists);
    //assert(exists ngsdoc = annotations(docAnnotation, ngs),
    //        ngsdoc.description == "AInterface.nonsharedGetterSetter");
    // TODO Test the setter annotations
    
    // TODO formalMethod
    assert(exists fm=iface.getFunction<AInterface, Function<Anything,[String]>>("formalMethod"));
    value fmd = fm(AClass("")).declaration;
    // TODO defaultMethod
    assert(exists dm=iface.getFunction<AInterface, Function<Anything,[String]>>("defaultMethod"));
    value dmd = dm(AClass("")).declaration;
    // TODO method
    assert(exists m=iface.getFunction<AInterface, Function<Anything,[String]>>("method"));
    value md = m(AClass("")).declaration;
    // TODO nonsharedMethod
    //assert(exists nsm=iface.getFunction<AInterface, Function<Anything,[String]>>("nonsharedMethod"));
    //value nsmd = nsm(AClass("")).declaration;
    
    // TODO Class & interface members
    variable ClassDeclaration ficd = memberClassDecl(aInterfaceDecl, "FormalInnerClass");
    variable ClassDeclaration dicd = memberClassDecl(aInterfaceDecl, "DefaultInnerClass");
    variable InterfaceDeclaration iid = memberInterfaceDecl(aInterfaceDecl, "SharedInnerInterface");
    
    // TODO Object members
    
    // Tests for annotatedMembers()
    value sharedClasses = aInterfaceDecl.annotatedMembers<ClassDeclaration, Shared>();
    assert(ficd in sharedClasses);
    assert(dicd in sharedClasses);
    assert(! iid in sharedClasses);
    assert(! fa in sharedClasses);
    assert(! gs in sharedClasses);
    // TODO assert(! ngs in sharedClasses);
    assert(! fmd in sharedClasses);
    assert(! dmd in sharedClasses);
    assert(! fmd in sharedClasses);
    assert(! md in sharedClasses);
    // TODO assert(! nsmd in sharedClasses);
    // TODO test with an object declaration
    
    value sharedInterfaces = aInterfaceDecl.annotatedMembers<InterfaceDeclaration, Shared>();
    assert(!ficd in sharedInterfaces);
    assert(!dicd in sharedInterfaces);
    assert(iid in sharedInterfaces);
    assert(! fa in sharedInterfaces);
    assert(! gs in sharedInterfaces);
    // TODO assert(! ngs in sharedInterfaces);
    assert(! fmd in sharedInterfaces);
    assert(! dmd in sharedInterfaces);
    assert(! fmd in sharedInterfaces);
    assert(! md in sharedInterfaces);
    // TODO assert(! nsmd in sharedInterfaces);
    // TODO test with an object declaration
    
    value sharedClassesAndInterfaces = aInterfaceDecl.annotatedMembers<ClassOrInterfaceDeclaration, Shared>();
    assert(ficd in sharedClassesAndInterfaces);
    assert(dicd in sharedClassesAndInterfaces);
    assert(iid in sharedClassesAndInterfaces);
    assert(! fa in sharedClassesAndInterfaces);
    assert(! gs in sharedClassesAndInterfaces);
    // TODO assert(! ngs in sharedClassesAndInterfaces);
    assert(! fmd in sharedClassesAndInterfaces);
    assert(! dmd in sharedClassesAndInterfaces);
    assert(! fmd in sharedClassesAndInterfaces);
    assert(! md in sharedClassesAndInterfaces);
    // TODO assert(! nsmd in sharedInterfaces);
    // TODO test with an object declaration
    
    value sharedAttributes = aInterfaceDecl.annotatedMembers<AttributeDeclaration, Shared>();
    assert(! ficd in sharedAttributes);
    assert(! dicd in sharedAttributes);
    assert(! iid in sharedAttributes);
    assert(fa in sharedAttributes);
    assert(gs in sharedAttributes);
    // TODO assert(ngs in sharedAttributes);
    assert(! fmd in sharedAttributes);
    assert(! dmd in sharedAttributes);
    assert(! fmd in sharedAttributes);
    assert(! md in sharedAttributes);
    // TODO assert(! nsmd in sharedAttribute);
    // TODO test with an object declaration
    
    value sharedVariables = aInterfaceDecl.annotatedMembers<VariableDeclaration, Shared>();
    assert(! ficd in sharedVariables);
    assert(! dicd in sharedVariables);
    assert(! iid in sharedVariables);
    assert(! fa in sharedVariables);
    assert(gs in sharedVariables);
    // TODO assert(ngs in sharedVariables);
    assert(! fmd in sharedVariables);
    assert(! dmd in sharedVariables);
    assert(! fmd in sharedVariables);
    assert(! md in sharedVariables);
    // TODO assert(! nsmd in sharedVariables);
    // TODO test with an object declaration
    
    value sharedMethods = aInterfaceDecl.annotatedMembers<FunctionDeclaration, Shared>();
    assert(! ficd in sharedMethods);
    assert(! dicd in sharedMethods);
    assert(! iid in sharedMethods);
    assert(! fa in sharedMethods);
    assert(! gs in sharedMethods);
    // TODO assert(! ngs in sharedMethods);
    assert(fmd in sharedMethods);
    assert(dmd in sharedMethods);
    assert(fmd in sharedMethods);
    assert(md in sharedMethods);
    // TODO assert(nsmd in sharedMethods);
    // TODO test with an object declaration
    
    value sharedAndDocdMethodsAndAttributes = aInterfaceDecl.annotatedMembers<FunctionDeclaration|AttributeDeclaration, Shared|Doc>();
    assert(! ficd in sharedAndDocdMethodsAndAttributes);
    assert(! dicd in sharedAndDocdMethodsAndAttributes);
    assert(! iid in sharedAndDocdMethodsAndAttributes);
    assert(fa in sharedAndDocdMethodsAndAttributes);
    assert(gs in sharedAndDocdMethodsAndAttributes);
    // TODO assert(! ngs in sharedAndDocdMethodsAndAttributes);
    assert(fmd in sharedAndDocdMethodsAndAttributes);
    assert(dmd in sharedAndDocdMethodsAndAttributes);
    assert(fmd in sharedAndDocdMethodsAndAttributes);
    assert(md in sharedAndDocdMethodsAndAttributes);
    // TODO assert(nsmd in sharedMethods);
    // TODO test with an object declaration
    
}

void checkModuleAndImports() {
    value m = aPackage.container;
    assert(exists moddoc = annotations(docAnnotation, m));
    assert(moddoc.description == "Some module doc");
    
    // module imports
    value deps = m.dependencies;
    assert(1 == deps.size);
    assert(exists dep = deps[0]);
    assert("java.base" == dep.name);
    assert("7" == dep.version);
    assert(exists depdoc = annotations(docAnnotation, dep));
    assert(depdoc.description == "Not actually needed, but we want to test ModuleImports");
    assert(annotations(optAnnotation, dep) exists);
    assert(annotations(deprecatedAnnotation, dep) exists);
    
}

void checkPackage() {
    value p = aPackage;
    assert(! annotations(sharedAnnotation, p) exists);
    assert(! annotations(docAnnotation, p) exists);
    
    // TODO each of these with a toplevel object declaration
    value sharedClasses = p.annotatedMembers<ClassDeclaration, Shared>();
    assert(aClassDecl in sharedClasses);
    assert(aAbstractClassDecl in sharedClasses);
    assert(! aInterfaceDecl in sharedClasses); // because it's not a class
    assert(! aToplevelAttributeDecl in sharedClasses);
    assert(! aToplevelGetterSetterDecl in sharedClasses);
    assert(! aToplevelFunctionDecl in sharedClasses);
    
    value sharedInterfaces = p.annotatedMembers<InterfaceDeclaration, Shared>();
    assert(! aClassDecl in sharedInterfaces);
    assert(! aAbstractClassDecl in sharedInterfaces);
    assert(aInterfaceDecl in sharedInterfaces);
    assert(! aToplevelAttributeDecl in sharedInterfaces);
    assert(! aToplevelGetterSetterDecl in sharedInterfaces);
    assert(! aToplevelFunctionDecl in sharedInterfaces);
    
    value sharedClassesAndInterfaces = p.annotatedMembers<ClassOrInterfaceDeclaration, Shared>();
    assert(aClassDecl in sharedClassesAndInterfaces);
    assert(aAbstractClassDecl in sharedClassesAndInterfaces);
    assert(aInterfaceDecl in sharedClassesAndInterfaces);
    assert(! aToplevelAttributeDecl in sharedClassesAndInterfaces);
    assert(! aToplevelGetterSetterDecl in sharedClassesAndInterfaces);
    assert(! aToplevelFunctionDecl in sharedClassesAndInterfaces);
    
    value sharedAttributes = p.annotatedMembers<AttributeDeclaration, Shared>();
    assert(! aClassDecl in sharedAttributes);
    assert(! aAbstractClassDecl in sharedAttributes);
    assert(! aInterfaceDecl in sharedAttributes);
    assert(aToplevelAttributeDecl in sharedAttributes);
    assert(aToplevelGetterSetterDecl in sharedAttributes);
    assert(! aToplevelFunctionDecl in sharedAttributes);
    
    value sharedVariables = p.annotatedMembers<VariableDeclaration, Shared>();
    assert(! aClassDecl in sharedVariables);
    assert(! aAbstractClassDecl in sharedVariables);
    assert(! aInterfaceDecl in sharedVariables);
    assert(! aToplevelAttributeDecl in sharedVariables);
    assert(aToplevelGetterSetterDecl in sharedVariables);
    assert(! aToplevelFunctionDecl in sharedVariables);
    
    value sharedFunctions = p.annotatedMembers<FunctionDeclaration, Shared>();
    assert(! aClassDecl in sharedFunctions);
    assert(! aAbstractClassDecl in sharedFunctions);
    assert(! aInterfaceDecl in sharedFunctions);
    assert(! aToplevelAttributeDecl in sharedFunctions);
    assert(! aToplevelGetterSetterDecl in sharedFunctions);
    assert(aToplevelFunctionDecl in sharedFunctions);
    
    // With a sequenced annotation
    value seqClasses = p.annotatedMembers<ClassDeclaration, Seq>();
    assert(aClassDecl in seqClasses);
    assert(aAbstractClassDecl in seqClasses);
    assert(! aInterfaceDecl in seqClasses); // because it's not a class
    assert(! aToplevelAttributeDecl in seqClasses);
    assert(! aToplevelGetterSetterDecl in seqClasses);
    assert(! aToplevelFunctionDecl in seqClasses);
    
    value seqInterfaces = p.annotatedMembers<InterfaceDeclaration, Seq>();
    assert(! aClassDecl in seqInterfaces);
    assert(! aAbstractClassDecl in seqInterfaces);
    assert(aInterfaceDecl in seqInterfaces);
    assert(! aToplevelAttributeDecl in seqInterfaces);
    assert(! aToplevelGetterSetterDecl in seqInterfaces);
    assert(! aToplevelFunctionDecl in seqInterfaces);
    
    value seqClassesAndInterfaces = p.annotatedMembers<ClassOrInterfaceDeclaration, Seq>();
    assert(aClassDecl in seqClassesAndInterfaces);
    assert(aAbstractClassDecl in seqClassesAndInterfaces);
    assert(aInterfaceDecl in seqClassesAndInterfaces);
    assert(! aToplevelAttributeDecl in seqClassesAndInterfaces);
    assert(! aToplevelGetterSetterDecl in seqClassesAndInterfaces);
    assert(! aToplevelFunctionDecl in seqClassesAndInterfaces);
    
    value seqAttributes = p.annotatedMembers<AttributeDeclaration, Seq>();
    assert(! aClassDecl in seqAttributes);
    assert(! aAbstractClassDecl in seqAttributes);
    assert(! aInterfaceDecl in seqAttributes);
    assert(aToplevelAttributeDecl in seqAttributes);
    assert(aToplevelGetterSetterDecl in seqAttributes);
    assert(! aToplevelFunctionDecl in seqAttributes);
    
    value seqVariables = p.annotatedMembers<VariableDeclaration, Seq>();
    assert(! aClassDecl in seqVariables);
    assert(! aAbstractClassDecl in seqVariables);
    assert(! aInterfaceDecl in seqVariables);
    assert(! aToplevelAttributeDecl in seqVariables);
    assert(aToplevelGetterSetterDecl in seqVariables);
    assert(! aToplevelFunctionDecl in seqVariables);
    
    value seqFunctions = p.annotatedMembers<FunctionDeclaration, Seq>();
    assert(! aClassDecl in seqFunctions);
    assert(! aAbstractClassDecl in seqFunctions);
    assert(! aInterfaceDecl in seqFunctions);
    assert(! aToplevelAttributeDecl in seqFunctions);
    assert(! aToplevelGetterSetterDecl in seqFunctions);
    assert(aToplevelFunctionDecl in seqFunctions);
    
    value sharedOrDocdCallables = p.annotatedMembers<FunctionDeclaration|ClassDeclaration, Shared|Doc>();
    assert(aClassDecl in sharedOrDocdCallables);
    assert(aAbstractClassDecl in sharedOrDocdCallables);
    assert(! aInterfaceDecl in sharedOrDocdCallables);
    assert(! aToplevelAttributeDecl in sharedOrDocdCallables);
    assert(! aToplevelGetterSetterDecl in sharedOrDocdCallables);
    assert(aToplevelFunctionDecl in sharedOrDocdCallables);
    
    value abstractCallables = p.annotatedMembers<FunctionDeclaration|ClassDeclaration, Abstract>();
    assert(! aClassDecl in abstractCallables);
    assert(aAbstractClassDecl in abstractCallables);
    assert(! aInterfaceDecl in abstractCallables);
    assert(! aToplevelAttributeDecl in abstractCallables);
    assert(! aToplevelGetterSetterDecl in abstractCallables);
    assert(! aToplevelFunctionDecl in abstractCallables);
    
    value sharedDeclarations = p.annotatedMembers<TopLevelOrMemberDeclaration, Shared>();
    assert(aClassDecl in sharedDeclarations);
    assert(aAbstractClassDecl in sharedDeclarations);
    assert(aInterfaceDecl in sharedDeclarations);
    assert(aToplevelAttributeDecl in sharedDeclarations);
    assert(aToplevelGetterSetterDecl in sharedDeclarations);
    assert(aToplevelFunctionDecl in sharedDeclarations);

}

void annotationTests() {
    checkAToplevelAttributeAnnotations();
    checkAToplevelGetterSetterAnnotations();
    checkAToplevelFunctionAnnotations();
    // TODO once we support objects
    // checkAToplevelObjectAnnotations();
    checkAInterface();
    checkAAbstractClass();
    checkAClass();
    // TODO Local declarations
    checkModuleAndImports();
    checkPackage();
    
}