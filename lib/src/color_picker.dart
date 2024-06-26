import 'package:flutter/material.dart';

import 'pickers/hsv_picker.dart';
import 'pickers/palette_hue_picker.dart';
import 'pickers/palette_saturation_picker.dart';
import 'pickers/palette_value_picker.dart';
import 'pickers/rgb_picker.dart';
import 'pickers/swatches_picker.dart';
import 'pickers/wheel_picker.dart';
import 'widgets/hex_picker.dart';

enum Picker {
  swatches,
  rgb,
  hsv,
  wheel,
  paletteHue,
  paletteSaturation,
  paletteValue,
}

/// The orientation of the ColorPicker.
enum PickerOrientation {
  /// The orientation is inherited from device's orientation.
  /// On web, if window width > height, the orientation is landscape.
  inherit,

  /// Always portrait mode.
  portrait,

  /// Always landscape mode.
  landscape,
}

/// Main color picker including all color pickers of this package.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    required this.onChanged,
    this.paletteHueText = 'Palette Hue',
    this.paletteValueText = 'Palette Value',
    this.paletteSaturationText = 'Palette Saturation',
    this.swatchesText = 'Swatches',
    this.wheelText = 'Wheel',
    this.placeholderText = 'Hex Code',
    this.color = Colors.blue,
    this.selectedTextColor = Colors.white,
    this.textColor = Colors.white,
    this.dropdownBgColor = Colors.grey,
    this.initialPicker = Picker.paletteHue,
    this.pickerOrientation = PickerOrientation.inherit,
    Key? key,
  }) : super(key: key);

  final ValueChanged<Color> onChanged;
  final Color color;

  final Color selectedTextColor;
  final Color textColor;
  final Color dropdownBgColor;

  final String swatchesText;
  final String wheelText;
  final String paletteHueText;
  final String paletteValueText;
  final String placeholderText;
  final String paletteSaturationText;

  /// The first picker widget that is shown.
  ///
  /// See also:
  ///
  ///  * [Picker] Enumeration of pickers.
  final Picker initialPicker;

  final PickerOrientation pickerOrientation;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  _ColorPickerState();

  // Color
  late Color _color;
  late HSVColor _hSVColor;
  late List<_IPicker> _pickers;
  late int _index;

  void _colorOnChanged(Color value) {
    _updateColor(value.withAlpha(_color.alpha));
  }

  void _hSVColorOnChanged(HSVColor value) {
    _updateColor(value.toColor().withAlpha(_color.alpha));
  }

  void _colorWithAlphaOnChanged(Color value) {
    _updateColor(value);
  }

  void _updateColor(Color color) {
    _color = color;
    _hSVColor = HSVColor.fromColor(color);
    widget.onChanged(color);
  }

  void _pickerOnChanged(_IPicker? value) {
    if (value != null) {
      _index = _pickers.indexOf(value);
    } else {
      _index = -1;
    }
  }

  @override
  void initState() {
    super.initState();

    _color = widget.color;
    _hSVColor = HSVColor.fromColor(_color);

    // Pickers
    _pickers = <_IPicker>[
      // SwatchesPicker
      _IPicker(
        name: widget.swatchesText, //'Swatches'
        picker: Picker.swatches,
        builder: (BuildContext context) => SwatchesPicker(
          onChanged: (Color value) => super.setState(
            () => _colorWithAlphaOnChanged(value),
          ),
        ),
      ),

      // RGBPicker
      _IPicker(
        name: 'RGB',
        picker: Picker.rgb,
        builder: (BuildContext context) => RGBPicker(
          color: _color,
          onChanged: (Color value) => super.setState(
            () => _colorOnChanged(value),
          ),
        ),
      ),

      // HSVPicker
      _IPicker(
        name: 'HSV',
        picker: Picker.hsv,
        builder: (BuildContext context) => HSVPicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),

      // WheelPicker
      _IPicker(
        name: widget.wheelText, //'Wheel',
        picker: Picker.wheel,
        builder: (BuildContext context) => WheelPicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),

      // PaletteHuePicker
      _IPicker(
        name: widget.paletteHueText, //'Palette Hue'
        picker: Picker.paletteHue,
        builder: (BuildContext context) => PaletteHuePicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),

      // PaletteSaturationPicker
      _IPicker(
        name: widget.paletteSaturationText, //'Palette Saturation'
        picker: Picker.paletteSaturation,
        builder: (BuildContext context) => PaletteSaturationPicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),

      // PaletteValuePicker
      _IPicker(
        name: widget.paletteValueText, //'Palette Value'
        picker: Picker.paletteValue,
        builder: (BuildContext context) => PaletteValuePicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),
    ];

    _index = _pickers.indexOf(
      _pickers.firstWhere((element) => element.picker == widget.initialPicker),
    );
  }

  // Dropdown
  DropdownMenuItem<_IPicker> _buildDropdownMenuItems(_IPicker item) {
    return DropdownMenuItem<_IPicker>(
      value: item,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
        child: Text(
          item.name,
          style: _index == _pickers.indexOf(item)
              ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    color: widget.selectedTextColor,
                  )
              : Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    color: widget.textColor,
                  ),
        ),
      ),
    );
  }

  Widget _buildHead() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Avator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                color: _color,
              ),
            ),
          ),

          const SizedBox(width: 22),

          // HexPicker
          Expanded(
            child: HexPicker(
              color: _color,
              placeholderText: widget.placeholderText,
              onChanged: (Color value) => super.setState(
                () => _colorOnChanged(value),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdownLandscapeMode() {
    return SizedBox(
      height: 38,
      child: Material(
        type: MaterialType.button,
        color: Theme.of(context).cardColor,
        shadowColor: Colors.black26,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: DropdownButton<_IPicker>(
          iconSize: 32.0,
          isExpanded: true,
          isDense: true,
          dropdownColor: widget.dropdownBgColor,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20,
              ),
          value: _pickers[_index],
          onChanged: (_IPicker? value) => super.setState(
            () => _pickerOnChanged(value),
          ),
          items: _pickers.map(_buildDropdownMenuItems).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdownPortraitMode() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: DropdownButton<_IPicker>(
        iconSize: 32.0,
        isExpanded: true,
        isDense: true,
        dropdownColor: widget.dropdownBgColor,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
            ),
        value: _pickers[_index],
        onChanged: (_IPicker? value) => super.setState(
          () => _pickerOnChanged(value),
        ),
        items: _pickers.map(_buildDropdownMenuItems).toList(),
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      child: _pickers[_index].builder(context),
    );
  }

  Orientation _getOrientation(PickerOrientation pickerOrientation) {
    switch (pickerOrientation) {
      case PickerOrientation.inherit:
        return MediaQuery.of(context).orientation;
      case PickerOrientation.portrait:
        return Orientation.portrait;
      case PickerOrientation.landscape:
        return Orientation.landscape;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = _getOrientation(widget.pickerOrientation);

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHead(),
            _buildDropdownPortraitMode(),
            _buildBody(),
          ],
        );

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildHead(),
                  _buildDropdownLandscapeMode(),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            )
          ],
        );
    }
  }
}

class _IPicker {
  _IPicker({
    required this.name,
    required this.picker,
    required this.builder,
  });

  String name;
  Picker picker;
  WidgetBuilder builder;
}
