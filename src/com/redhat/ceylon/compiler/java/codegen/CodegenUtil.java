/*
 * Copyright Red Hat Inc. and/or its affiliates and other contributors
 * as indicated by the authors tag. All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 * 
 * This particular file is subject to the "Classpath" exception as provided in the 
 * LICENSE file that accompanied this code.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT A
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License,
 * along with this distribution; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 */
package com.redhat.ceylon.compiler.java.codegen;

import java.util.Map;

import com.redhat.ceylon.compiler.java.codegen.AbstractTransformer.BoxingStrategy;
import com.redhat.ceylon.compiler.java.util.Util;
import com.redhat.ceylon.compiler.typechecker.model.Class;
import com.redhat.ceylon.compiler.typechecker.model.Declaration;
import com.redhat.ceylon.compiler.typechecker.model.Functional;
import com.redhat.ceylon.compiler.typechecker.model.Method;
import com.redhat.ceylon.compiler.typechecker.model.MethodOrValue;
import com.redhat.ceylon.compiler.typechecker.model.Parameter;
import com.redhat.ceylon.compiler.typechecker.model.ProducedType;
import com.redhat.ceylon.compiler.typechecker.model.Specification;
import com.redhat.ceylon.compiler.typechecker.model.TypedDeclaration;
import com.redhat.ceylon.compiler.typechecker.model.Value;
import com.redhat.ceylon.compiler.typechecker.tree.Tree;
import com.redhat.ceylon.compiler.typechecker.tree.Tree.BaseMemberExpression;
import com.redhat.ceylon.compiler.typechecker.tree.Tree.CompilerAnnotation;
import com.redhat.ceylon.compiler.typechecker.tree.Tree.Term;

/**
 * Utility functions that are specific to the codegen package
 * @see Util
 */
class CodegenUtil {

    
    private CodegenUtil(){}
    

    static boolean isErasedAttribute(String name){
        // ERASURE
        return "hash".equals(name) || "string".equals(name);
    }

    static boolean isSmall(TypedDeclaration declaration) {
        return "hash".equals(declaration.getName());
    }



    static boolean isUnBoxed(Term node){
        return node.getUnboxed();
    }

    static boolean isUnBoxed(TypedDeclaration decl){
        // null is considered boxed
        return decl.getUnboxed() == Boolean.TRUE;
    }

    static void markUnBoxed(Term node) {
        node.setUnboxed(true);
    }

    static BoxingStrategy getBoxingStrategy(Term node) {
        return isUnBoxed(node) ? BoxingStrategy.UNBOXED : BoxingStrategy.BOXED;
    }

    static BoxingStrategy getBoxingStrategy(TypedDeclaration decl) {
        return isUnBoxed(decl) ? BoxingStrategy.UNBOXED : BoxingStrategy.BOXED;
    }

    static boolean isRaw(TypedDeclaration decl){
        ProducedType type = decl.getType();
        return type != null && type.isRaw();
    }

    static boolean isRaw(Term node){
        ProducedType type = node.getTypeModel();
        return type != null && type.isRaw();
    }

    static void markRaw(Term node) {
        ProducedType type = node.getTypeModel();
        if(type != null)
            type.setRaw(true);
    }
    
    static boolean hasTypeErased(Term node){
        return node.getTypeErased();
    }

    static boolean hasTypeErased(TypedDeclaration decl){
        return decl.getTypeErased();
    }

    static void markTypeErased(Term node) {
        markTypeErased(node, true);
    }

    static void markTypeErased(Term node, boolean erased) {
        node.setTypeErased(erased);
    }

    /**
     * Determines if the given statement or argument has a compiler annotation 
     * with the given name.
     * 
     * @param decl The statement or argument
     * @param name The compiler annotation name
     * @return true if the statement or argument has an annotation with the 
     * given name
     * 
     * @see #hasCompilerAnnotationWithArgument(com.redhat.ceylon.compiler.typechecker.tree.Tree.Declaration, String, String)
     */
    static boolean hasCompilerAnnotation(Tree.StatementOrArgument decl, String name){
        for(CompilerAnnotation annotation : decl.getCompilerAnnotations()){
            if(annotation.getIdentifier().getText().equals(name))
                return true;
        }
        return false;
    }
    
    /**
     * Determines if the given statement or argument has a compiler annotation 
     * with the given name and with the given argument.
     * 
     * @param decl The statement or argument
     * @param name The compiler annotation name
     * @param argument The compiler annotation's argument
     * @return true if the statement or argument has an annotation with the 
     * given name and argument value
     * 
     * @see #hasCompilerAnnotation(com.redhat.ceylon.compiler.typechecker.tree.Tree.Declaration, String)
     */
    static boolean hasCompilerAnnotationWithArgument(Tree.StatementOrArgument decl, String name, String argument){
        for (CompilerAnnotation annotation : decl.getCompilerAnnotations()) {
            if (annotation.getIdentifier().getText().equals(name)) {
                if (annotation.getStringLiteral() == null) {
                    continue;
                } 
                String text = annotation.getStringLiteral().getText();
                if (text == null) {
                    continue;
                }
                text = text.substring(1, text.length()-1);//remove "";
                if (text.equals(argument)) {
                    return true;
                }
            }
        }
        return false;
    }


    static boolean isDirectAccessVariable(Term term) {
        if(!(term instanceof BaseMemberExpression))
            return false;
        Declaration decl = ((BaseMemberExpression)term).getDeclaration();
        if(decl == null) // typechecker error
            return false;
        // make sure we don't try to optimise things which can't be optimised
        return Decl.isValue(decl)
                && !decl.isToplevel()
                && !decl.isClassOrInterfaceMember()
                && !decl.isCaptured()
                && !decl.isShared();
    }

    static Declaration getTopmostRefinedDeclaration(Declaration decl){
        return getTopmostRefinedDeclaration(decl, null);
    }

    static Declaration getTopmostRefinedDeclaration(Declaration decl, Map<Method, Method> methodOverrides){
        if (decl instanceof Parameter && decl.getContainer() instanceof Class) {
            // Parameters in a refined class are not considered refinements themselves
            // We have in find the refined attribute
            Class c = (Class)decl.getContainer();
            if (c.isAlias()) {
                int index = c.getParameterList().getParameters().indexOf(decl);
                while (c.isAlias()) {
                    c = c.getExtendedTypeDeclaration();
                }
                decl = c.getParameterList().getParameters().get(index);
            }
            Declaration refinedDecl = c.getRefinedMember(decl.getName(), null, false);//?? elipses=false??
            if(refinedDecl != null && refinedDecl != decl) {
                return getTopmostRefinedDeclaration(refinedDecl, methodOverrides);
            }
            return decl;
        } else if(decl instanceof Parameter 
                && (decl.getContainer() instanceof Method || decl.getContainer() instanceof Specification)){
            // Parameters in a refined method are not considered refinements themselves
            // so we have to look up the corresponding parameter in the container's refined declaration
            Method func;
            if(decl.getContainer() instanceof Method)
                func = (Method)decl.getContainer();
            else
                func = (Method) ((Specification)decl.getContainer()).getDeclaration();
            if(func == null)
                return decl;
            Parameter param = (Parameter)decl;
            Method refinedFunc = (Method) getTopmostRefinedDeclaration(func, methodOverrides);
            // shortcut if the functional doesn't override anything
            if(refinedFunc == func)
                return decl;
            if (func.getParameterLists().size() != refinedFunc.getParameterLists().size()) {
                // invalid input
                return decl;
            }
            for (int ii = 0; ii < func.getParameterLists().size(); ii++) {
                if (func.getParameterLists().get(ii).getParameters().size() != refinedFunc.getParameterLists().get(ii).getParameters().size()) {
                    // invalid input
                    return decl;
                }
                // find the index of the parameter
                int index = func.getParameterLists().get(ii).getParameters().indexOf(param);
                if (index == -1) {
                    continue;
                }
                return refinedFunc.getParameterLists().get(ii).getParameters().get(index);
            }
        }else if(methodOverrides != null
                && decl instanceof Method
                && decl.getRefinedDeclaration() == decl
                && decl.getContainer() instanceof Specification
                && ((Specification)decl.getContainer()).getDeclaration() instanceof Method
                && ((Method) ((Specification)decl.getContainer()).getDeclaration()).isShortcutRefinement()
                // we do all the previous ones first because they are likely to filter out false positives cheaper than the
                // hash lookup we do next to make sure it is really one of those cases
                && methodOverrides.containsKey(decl)){
            // special case for class X() extends T(){ m = function() => e; } which we inline
            decl = methodOverrides.get(decl);
        }
        Declaration refinedDecl = decl.getRefinedDeclaration();
        if(refinedDecl != null && refinedDecl != decl)
            return getTopmostRefinedDeclaration(refinedDecl);
        return decl;
    }
    
    static Parameter findParamForDecl(Tree.TypedDeclaration decl) {
        String attrName = decl.getIdentifier().getText();
        return findParamForDecl(attrName, decl.getDeclarationModel());
    }
    
    static Parameter findParamForDecl(TypedDeclaration decl) {
        String attrName = decl.getName();
        return findParamForDecl(attrName, decl);
    }
    
    static Parameter findParamForDecl(String attrName, TypedDeclaration decl) {
        Parameter result = null;
        if (decl.getContainer() instanceof Functional) {
            Functional f = (Functional)decl.getContainer();
            result = f.getParameter(attrName);
        }
        return result;
    }
    
    static MethodOrValue findMethodOrValueForParam(Parameter param) {
        MethodOrValue result = null;
        String attrName = param.getName();
        Declaration member = param.getContainer().getDirectMember(attrName, null, false);
        if (member instanceof MethodOrValue) {
            result = (MethodOrValue)member;
        }
        return result;
    }

    static boolean isVoid(ProducedType type) {
        return type != null && type.getDeclaration() != null
                && type.getDeclaration().getUnit().getAnythingDeclaration().getType().isExactly(type);    
    }


    public static boolean canOptimiseMethodSpecifier(Term expression, Method m) {
        if(expression instanceof Tree.FunctionArgument)
            return true;
        if(expression instanceof Tree.BaseMemberOrTypeExpression == false)
            return false;
        Declaration declaration = ((Tree.BaseMemberOrTypeExpression)expression).getDeclaration();
        // methods are fine because they are constant
        if(declaration instanceof Method)
            return true;
        // toplevel constructors are fine
        if(declaration instanceof Class)
            return true;
        // parameters are constant too
        if(declaration instanceof Parameter)
            return true;
        // the rest we can't know: we can't trust attributes that could be getters or overridden
        // we can't trust even toplevel attributes that could be made variable in the future because of
        // binary compat.
        return false;
    }
}
