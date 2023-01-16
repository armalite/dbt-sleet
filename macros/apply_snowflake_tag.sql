
{% macro apply_snowflake_tag(object_type, object_name, tag_name, tag_value) %}

  {% if object_type is not none and object_name is not none and tag_name is not none and tag_value is not none  %}
    
    {% set object_type_list = object_type.split(' ') %}
    {% set tag_name_short = tag_name.split('.')[2] %}
    {% set object_name_short = object_name.split('.')[1] ~ '.' ~ object_name.split('.')[2] %}
    {% if object_type_list is iterable and object_type_list|length > 1 and object_type_list[1].upper() == "COLUMN" %}          
        {% set object_name_list = object_name.split('.') %}
        {% if object_name_list[3] is not none %}
            {% set apply_tag_query %}
                ALTER {{ object_type_list[0].upper() }} {{ object_name_list[0].upper() ~ '.' ~ object_name_list[1].upper() ~ '.' ~ object_name_list[2].upper() }} MODIFY COLUMN {{ object_name_list[3] }} SET TAG {{ tag_name.upper() }} = '{{ tag_value }}'
            {% endset %}
        {% else %}
            {{ log( "A column name must be added to the fully qualified object name, when object_type is set to TABLE COLUMN or VIEW COLUMN. Supported structure: DATABASE.SCHEMA.TABLE.COLUMN", info=True) }}
        {% endif %}
        {% do run_query(apply_tag_query) %}
        {{ log( "Successfully applied tag: " ~ tag_name_short ~ ", with value: " ~ tag_value ~ ", on column: " ~ object_name_list[3] ~ ", in " ~ object_type_list[0] ~ ": " ~ object_name_short, info=True) }}
    {% else %}   
        {% set apply_tag_query %}
            ALTER {{ object_type_list[0].upper() }} {{ object_name.upper() }} SET TAG {{ tag_name.upper() }} = '{{ tag_value }}';
        {% endset %}
        {% do run_query(apply_tag_query) %}
        {{ log( "Successfully applied tag: " ~ tag_name_short ~ ", with value: " ~ tag_value ~ ", on " ~ object_type ~ ": " ~ object_name_short, info=True) }}
    {% endif %}  
  {% else %}
    {{ log( "Macro arguments cannot be empty", info=True) }}
    
  {% endif %}

{% endmacro %}