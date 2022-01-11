import 'package:nyxx/nyxx.dart';

/// Allows to create components
abstract class ComponentBuilderAbstract extends Builder {
  /// Type of component
  ComponentType get type;

  @override
  Map<String, dynamic> build() => {
        "type": type.value,
      };
}

/// Allows to create multi select option for [MultiselectBuilder]
class MultiselectOptionBuilder extends Builder {
  /// User-facing name of the option
  final String label;

  /// Internal value of option
  final String value;

  /// Setting to true will render this option as pre-selected
  final bool isDefault;

  /// An additional description to option
  String? description;

  /// Emoji displayed alongside with label
  IEmoji? emoji;

  /// Creates instance of [MultiselectOptionBuilder]
  MultiselectOptionBuilder(this.label, this.value, [this.isDefault = false]);

  @override
  RawApiMap build() => {
        "label": label,
        "value": value,
        "default": isDefault,
        if (emoji != null)
          "emoji": {
            if (emoji is IBaseGuildEmoji) "id": (emoji as IBaseGuildEmoji).id.toString(),
            if (emoji is UnicodeEmoji) "name": (emoji as UnicodeEmoji).code,
            if (emoji is IGuildEmoji) "animated": (emoji as IGuildEmoji).animated,
          },
        if (description != null) "description": description,
      };
}

/// Allows to create multi select interactive components.
class MultiselectBuilder extends ComponentBuilderAbstract {
  @override
  ComponentType get type => ComponentType.select;

  /// Max: 100 characters
  final String customId;

  /// Max: 25
  final List<MultiselectOptionBuilder> options = [];

  /// Custom placeholder when nothing selected
  String? placeholder;

  /// Minimum number of options that can be chosen.
  /// Default: 1, min: 1, max: 25
  int? minValues;

  /// Maximum numbers of options that can be chosen
  /// Default: 1, min: 1, max: 25
  int? maxValues;

  /// Creates instance of [MultiselectBuilder]
  MultiselectBuilder(this.customId, [Iterable<MultiselectOptionBuilder>? options]) {
    if (customId.length > 100) {
      throw ArgumentError("Custom Id for Select cannot have more than 100 characters");
    }

    if (options != null) {
      this.options.addAll(options);
    }
  }

  /// Adds option to dropdown
  void addOption(MultiselectOptionBuilder builder) => options.add(builder);

  @override
  Map<String, dynamic> build() => {
        ...super.build(),
        "custom_id": customId,
        "options": [for (final optionBuilder in options) optionBuilder.build()],
        if (placeholder != null) "placeholder": placeholder,
        if (minValues != null) "min_values": minValues,
        if (maxValues != null) "max_values": maxValues,
      };
}

/// Allows to build button. Generic interface for all types of buttons
abstract class ButtonBuilderAbstract extends ComponentBuilderAbstract {
  @override
  ComponentType get type => ComponentType.button;

  /// Label for button. Max 80 characters.
  final String label;

  /// Style of button. See [ComponentStyle]
  final ComponentStyle style;

  /// True if emoji is disabled
  bool disabled = false;

  /// Additional emoji for button
  IEmoji? emoji;

  /// Creates instance of [ButtonBuilderAbstract]
  ButtonBuilderAbstract(this.label, this.style, {this.disabled = false, this.emoji}) {
    if (label.length > 80) {
      throw ArgumentError("Label for Button cannot have more than 80 characters");
    }
  }

  @override
  Map<String, dynamic> build() => {
        ...super.build(),
        "label": label,
        "style": style.value,
        if (disabled) "disabled": true,
        if (emoji != null)
          "emoji": {
            if (emoji is IBaseGuildEmoji) "id": (emoji as IBaseGuildEmoji).id.toString(),
            if (emoji is UnicodeEmoji) "name": (emoji as UnicodeEmoji).code,
            if (emoji is IGuildEmoji) "animated": (emoji as IGuildEmoji).animated,
          }
      };
}

/// Allows to create a button with link
class LinkButtonBuilder extends ButtonBuilderAbstract {
  /// Url where his button should redirect
  final String url;

  /// Creates instance of [LinkButtonBuilder]
  LinkButtonBuilder(String label, this.url, {bool disabled = false, IEmoji? emoji}) : super(label, ComponentStyle.link, disabled: disabled, emoji: emoji) {
    if (url.length > 512) {
      throw ArgumentError("Url for button cannot have more than 512 characters");
    }
  }

  @override
  RawApiMap build() => {...super.build(), "url": url};
}

/// Button which will generate event when clicked.
class ButtonBuilder extends ButtonBuilderAbstract {
  /// Id with optional additional metadata for button.
  String customId;

  /// Creates instance of [ButtonBuilder]
  ButtonBuilder(String label, this.customId, ComponentStyle style, {bool disabled = false, IEmoji? emoji})
      : super(label, style, disabled: disabled, emoji: emoji) {
    if (customId.length > 100) {
      throw ArgumentError("customId for button cannot have more than 100 characters");
    }
  }

  @override
  RawApiMap build() => {...super.build(), "custom_id": customId};
}

/// Helper builder to provide fluid api for building component rows
class ComponentRowBuilder {
  final List<ComponentBuilderAbstract> _components = [];

  /// Adds component to row
  void addComponent(ComponentBuilderAbstract componentBuilder) => _components.add(componentBuilder);
}

/// Extended [MessageBuilder] with support for buttons
class ComponentMessageBuilder extends MessageBuilder {
  /// Set of buttons to attach to message. Message can only have 5 rows with 5 buttons each.
  List<List<ComponentBuilderAbstract>>? componentRows;

  /// Allows to add
  void addComponentRow(ComponentRowBuilder componentRowBuilder) {
    componentRows ??= [];

    if (componentRowBuilder._components.length > 5 || componentRowBuilder._components.isEmpty) {
      throw ArgumentError("Component row cannot be empty or have more than 5 components");
    }

    if (componentRows!.length == 5) {
      throw ArgumentError("Maximum number of component rows is 5");
    }

    componentRows!.add(componentRowBuilder._components);
  }

  @override
  RawApiMap build([AllowedMentions? defaultAllowedMentions]) => {
        ...super.build(allowedMentions),
        if (componentRows != null)
          "components": [
            for (final row in componentRows!)
              {
                "type": ComponentType.row.value,
                "components": [for (final component in row) component.build()]
              }
          ]
      };
}
