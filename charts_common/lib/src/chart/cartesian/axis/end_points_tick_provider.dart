// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:meta/meta.dart' show required;

import '../../../common/graphics_factory.dart' show GraphicsFactory;
import '../../common/chart_context.dart' show ChartContext;
import 'axis.dart' show AxisOrientation;
import 'draw_strategy/tick_draw_strategy.dart' show TickDrawStrategy;
import 'numeric_scale.dart' show NumericScale;
import 'ordinal_scale.dart' show OrdinalScale;
import 'scale.dart' show MutableScale;
import 'tick.dart' show Tick;
import 'tick_formatter.dart' show TickFormatter;
import 'tick_provider.dart' show BaseTickProvider, TickHint;
import 'time/date_time_scale.dart' show DateTimeScale;

/// Tick provider that provides ticks at the two end points of the axis range.
class EndPointsTickProvider<D> extends BaseTickProvider<D> {
  final bool isDay;
  const EndPointsTickProvider({this.isDay = false});

  @override
  List<Tick<D>> getTicks({
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required MutableScale<D> scale,
    @required TickFormatter<D> formatter,
    @required Map<D, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    @required AxisOrientation orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D> tickHint,
  }) {
    final ticks = <Tick<D>>[];

    // Check to see if the axis has been configured with some domain values.
    //
    // An un-configured axis has no domain step size, and its scale defaults to
    // infinity.
    if (scale.domainStepSize.abs() != double.infinity) {
      List<D> values;
      final start = _getStartValue(tickHint, scale);
      final end = _getEndValue(tickHint, scale);
      final middle = _getPercentValue(tickHint, scale, 0.5);
      if (isDay) {
        values = [start, middle, end];
      } else {
        final middleLeft = _getPercentValue(tickHint, scale, 0.25);
        final middleRight = _getPercentValue(tickHint, scale, 0.75);
        values = [start, middleLeft, middle, middleRight, end];
      }
      final labels = formatter.format(values, formatterValueCache,
          stepSize: scale.domainStepSize);
      for (int i = 0; i < labels.length; i++) {
        ticks.add(Tick(
            value: values[i],
            textElement: graphicsFactory.createTextElement(labels[i]),
            locationPx: scale[values[i]]));
      }
      // Allow draw strategy to decorate the ticks.
      tickDrawStrategy.decorateTicks(ticks);
    }

    return ticks;
  }

  /// Get the start value from the scale.
  D _getStartValue(TickHint<D> tickHint, MutableScale<D> scale) {
    Object start;

    if (tickHint != null) {
      start = tickHint.start;
    } else {
      if (scale is NumericScale) {
        start = (scale as NumericScale).viewportDomain.min;
      } else if (scale is DateTimeScale) {
        start = (scale as DateTimeScale).viewportDomain.start;
      } else if (scale is OrdinalScale) {
        start = (scale as OrdinalScale).domain.first;
      }
    }

    return start;
  }

  /// Get the end value from the scale.
  D _getEndValue(TickHint<D> tickHint, MutableScale<D> scale) {
    Object end;

    if (tickHint != null) {
      end = tickHint.end;
    } else {
      if (scale is NumericScale) {
        end = (scale as NumericScale).viewportDomain.max;
      } else if (scale is DateTimeScale) {
        end = (scale as DateTimeScale).viewportDomain.end;
      } else if (scale is OrdinalScale) {
        end = (scale as OrdinalScale).domain.last;
      }
    }

    return end;
  }

  /// Get the percent value from the scale.
  D _getPercentValue(TickHint<D> tickHint, MutableScale<D> scale, double percent) {
    Object percentValue;

    if (tickHint != null) {
      percentValue = tickHint.start;
    } else {
      if (scale is NumericScale) {
        NumericScale numScale = (scale as NumericScale);
        percentValue = percent == 0.5 ? numScale.viewportDomain.middle : (percent == 0.25 ? numScale.viewportDomain.middleLeft : numScale.viewportDomain.middleRight);
      } else if (scale is DateTimeScale) {
        DateTimeScale dateScale = (scale as DateTimeScale);
        percentValue = percent == 0.5 ? dateScale.viewportDomain.middle(isDay: isDay) : (percent == 0.25 ? dateScale.viewportDomain.middleLeft(isDay: isDay) : dateScale.viewportDomain.middleRight(isDay: isDay));
      } else if (scale is OrdinalScale) {
        percentValue = "";
      }
    }

    return percentValue;
  }
}
