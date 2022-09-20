{% macro apply_snowflake_tag(parent_object_type, target_object_type, target_object_name, tag_name, tag_value) %}

  {% if target_object_name is not none and parent_object_type is not none and target_object_type is not none and tag_name is not none and tag_value is not none  %}
    
    {% set tag_name_short = tag_name.split('.')[2] %}
    {% set object_name_short = target_object_name.split('.')[1] ~ '.' ~ target_object_name.split('.')[2] %}
    {% if target_object_type == "COLUMN"  %} 
            
        {% set object_name_list = target_object_name.split('.') %}
        {% if object_name_list[3] is not none %}
            {% set apply_tag_query %}
                ALTER {{ parent_object_type.upper() }} {{ object_name_list[0].upper() ~ '.' ~ object_name_list[1].upper() ~ '.' ~ object_name_list[2].upper() }} MODIFY COLUMN {{ object_name_list[3] }} SET TAG {{ tag_name.upper() }} = '{{ tag_value }}'
            {% endset %}
        {% else %}
            {{ log( "A column name must be added to the fully qualified object name, when target_object_type is set to COLUMN. Supported structure: DATABASE.SCHEMA.TABLE.COLUMN", info=True) }}
        {% endif %}
        {% do run_query(apply_tag_query) %}
        {{ log( "Successfully applied tag: " ~ tag_name_short ~ ", with value: " ~ tag_value ~ ", on column: " ~ object_name_list[3] ~ ", in " ~ parent_object_type ~ ": " ~ object_name_short, info=True) }}
    {% else %}

        {% set apply_tag_query %}
            ALTER {{ target_object_type.upper() }} {{ target_object_name.upper() }} SET TAG {{ tag_name.upper() }} = '{{ tag_value }}';
        {% endset %}
        {% do run_query(apply_tag_query) %}
        {{ log( "Successfully applied tag: " ~ tag_name_short ~ ", with value: " ~ tag_value ~ ", on " ~ target_object_type ~ ": " ~ object_name_short, info=True) }}
    {% endif %} 
    
  {% else %}
    {{ log( "Macro arguments cannot be empty", info=True) }}
  {% endif %}

{% endmacro %}