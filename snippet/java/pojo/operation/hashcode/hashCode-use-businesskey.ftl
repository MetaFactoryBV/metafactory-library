<#include "/include/model/findBusinessKeys.ftl" >

<#--stop if $operationPattern is null-->
<#if !(operationPattern)??>  <#stop "operationPattern not found in context => Is this snippet used to create a method?" ></#if>

<#assign apicomment = operationPattern.getChild("apicomment", nsPattern) >
<#assign apicommentText = "Fields used as businesskey:" >

int result;
<#if (businessKeyFields.size()==0) >
  // FIXME: no businesskey fields defined
  result = super.hashCode();
<#else>
  result=14;

  <#list businessKeyFields as field>
    <#if (field.getName()=="attribute") >
        <#assign attributeName = field.getAttributeValue("name") >
        <#assign attributeType = field.getAttributeValue("type") >
        <#assign attributeNameFU = generator.firstUpper(attributeName) >
        <#if (generator.isPrimitiveJavaType(attributeType)) >
          <#if (attributeType == "bool" || attributeType == "boolean") >
            result = 29*result + Boolean.valueOf(${attributeName}).hashCode(); <#-- prevents a PMD error -->
          <#else>
            result = 29*result + new ${generator.getJavaWrapperClass(attributeType)}(${attributeName}).hashCode();
          </#if>
        <#else>
          <#-- handle primitivetypes other than objects -->
          if (${attributeName} != null) {
            result = 29*result + this.get${generator.firstUpper(attributeName)}().hashCode();
          }
        </#if>
    <#elseif (field.getName()=="reference") >
        <#assign referenceName = field.getAttributeValue("name") >
        <#assign referenceType = field.getAttributeValue("type") >
        <#assign referenceNameFU = referenceName?cap_first >
        if (${referenceName} != null) {
          result = 17*result + ${referenceName}.hashCode();
        }
    <#else>
      <#stop "Unexpected businessKey element found: ${field.getElementName()}. Only attribute of reference expected." >
    </#if>
    <#--Add this field to the apicomment -->
    <#assign previousComment = apicommentText >
    <#assign counter = field_index + 1 >
    <#assign apicommentText = " ${previousComment} ${counter}) ${field.getAttributeValue('name')}" >
  </#list>
  <#assign apicommentText = "${apicommentText}." >
  ${generatedOperation.setApiComment(apicommentText)}
</#if>
return result;
