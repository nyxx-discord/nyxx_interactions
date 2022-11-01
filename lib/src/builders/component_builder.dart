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

/// Abstract base class that represents any multi select builer.
abstract class MultiSelectBuilderAbstract extends ComponentBuilderAbstract {
  /// Id for the select menu; max 100 characters.
  final String customId;

  /// Placeholder text if nothing is selected; max 150 characters.
  String? placeholder;

  /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25.
  int? minValues;

  /// Maximum number of items that can be chosen (defaults to 1); max 25.
  int? maxValues;

  /// Whether select menu is disabled (defaults to `false`).
  bool? disabled;

  MultiSelectBuilderAbstract(this.customId) {
    if (customId.length > 100) {
      throw ArgumentError("Custom Id for Select cannot have more than 100 characters");
    }
  }

  @override
  Map<String, dynamic> build() => {
        ...super.build(),
        'custom_id': customId,
        if (placeholder != null) 'placeholder': placeholder,
        if (minValues != null) 'min_values': minValues,
        if (maxValues != null) 'max_values': maxValues,
        if (disabled != null) 'disabled': disabled,
      };
}

/// Allows to create multi select options for [MultiselectBuilder].
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
class MultiselectBuilder extends MultiSelectBuilderAbstract {
  @override
  ComponentType get type => ComponentType.multiSelect;

  /// Max: 25
  final List<MultiselectOptionBuilder> options = [];

  /// Creates instance of [MultiselectBuilder]
  MultiselectBuilder(super.customId, [Iterable<MultiselectOptionBuilder>? options]) {
    if (options != null) {
      this.options.addAll(options);
    }
  }

  /// Adds option to dropdown
  void addOption(MultiselectOptionBuilder builder) => options.add(builder);

  @override
  Map<String, dynamic> build() => {
        ...super.build(),
        "options": [for (final optionBuilder in options) optionBuilder.build()],
      };
}

/// Builder to create select menu with [IUser]s inside of it.
class UserMultiSelectBuilder extends MultiSelectBuilderAbstract {
  @override
  ComponentType get type => ComponentType.userMultiSelect;

  UserMultiSelectBuilder(super.customId);
}

/// Builder to create select menu with [IRole]s inside of it.
class RoleMultiSelectBuilder extends MultiSelectBuilderAbstract {
  @override
  ComponentType get type => ComponentType.roleMultiSelect;

  RoleMultiSelectBuilder(super.customId);
}

/// Builder to create select menu with mentionables ([IRole]s & [IUser]s) inside of it.
class MentionableMultiSelectBuilder extends MultiSelectBuilderAbstract {
  @override
  ComponentType get type => ComponentType.mentionableMultiSelect;

  MentionableMultiSelectBuilder(super.customId);
}

/// Builder to create select menu with [IChannel]s inside of it.
class ChannelMultiSelectBuilder extends MultiSelectBuilderAbstract {
  @override
  ComponentType get type => ComponentType.channelMultiSelect;

  List<ChannelType>? channelTypes;

  ChannelMultiSelectBuilder(super.customId, [this.channelTypes]);

  @override
  Map<String, dynamic> build() => {
        ...super.build(),
        if (channelTypes != null) 'channel_types': channelTypes!.map((e) => e.value).toList(),
      };
}

/// Allows to build button. Generic interface for all types of buttons
abstract class ButtonBuilderAbstract extends ComponentBuilderAbstract {
  @override
  ComponentType get type => ComponentType.button;

  /// Label for button. Max 80 characters.
  final String label;

  /// Style of button. See [ButtonStyle]
  final ButtonStyle style;

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
  LinkButtonBuilder(String label, this.url, {bool disabled = false, IEmoji? emoji}) : super(label, ButtonStyle.link, disabled: disabled, emoji: emoji) {
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
  ButtonBuilder(String label, this.customId, ButtonStyle style, {bool disabled = false, IEmoji? emoji})
      : super(label, style, disabled: disabled, emoji: emoji) {
    if (customId.length > 100) {
      throw ArgumentError("customId for button cannot have more than 100 characters");
    }
  }

  @override
  RawApiMap build() => {...super.build(), "custom_id": customId};
}

class TextInputStyle extends IEnum<int> {
  static const short = TextInputStyle(1);
  static const paragraph = TextInputStyle(2);

  const TextInputStyle(int value) : super(value);
  TextInputStyle.from(int value) : super(value);
}

class TextInputBuilder extends ComponentBuilderAbstract {
  @override
  ComponentType get type => ComponentType.text;

  TextInputStyle style;

  String customId;

  String label;

  String? placeholder;

  String? value;

  bool? required;

  int? minLength;

  int? maxLength;

  TextInputBuilder(this.customId, this.style, this.label);

  @override
  RawApiMap build() => {
        ...super.build(),
        "style": style.value,
        "custom_id": customId,
        "label": label,
        "placeholder": placeholder,
        "value": value,
        "required": required,
        "min_length": minLength,
        "max_length": maxLength,
      };
}

/// Helper builder to provide fluid api for building component rows
class ComponentRowBuilder implements Builder {
  final List<ComponentBuilderAbstract> _components = [];

  /// Adds component to row
  void addComponent(ComponentBuilderAbstract componentBuilder) => _components.add(componentBuilder);

  @override
  RawApiMap build() => {
        "type": ComponentType.row.value,
        "components": [for (final component in _components) component.build()]
      };
}

/// Extended [MessageBuilder] with support for buttons
class ComponentMessageBuilder extends MessageBuilder {
  /// Set of buttons to attach to message. Message can only have 5 rows with 5 buttons each.
  List<ComponentRowBuilder>? componentRows;

  /// Allows to add
  void addComponentRow(ComponentRowBuilder componentRowBuilder) {
    componentRows ??= [];

    if (componentRowBuilder._components.length > 5 || componentRowBuilder._components.isEmpty) {
      throw ArgumentError("Component row cannot be empty or have more than 5 components");
    }

    if (componentRows!.length == 5) {
      throw ArgumentError("Maximum number of component rows is 5");
    }

    componentRows!.add(componentRowBuilder);
  }

  @override
  RawApiMap build([AllowedMentions? defaultAllowedMentions]) => {
        ...super.build(allowedMentions),
        if (componentRows != null) "components": [for (final row in componentRows!) row.build()]
      };
}
