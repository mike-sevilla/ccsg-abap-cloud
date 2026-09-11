CLASS zcx_cc_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.

    CONSTANTS:
      BEGIN OF no_rule,
        msgid TYPE symsgid      VALUE 'SABP_UNIT',
        msgno TYPE symsgno      VALUE '000',
        attr1 TYPE scx_attrname VALUE 'MV_TEXT',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_rule.

    DATA mv_text TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                !text     TYPE string                   OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcx_cc_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    mv_text = text.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
