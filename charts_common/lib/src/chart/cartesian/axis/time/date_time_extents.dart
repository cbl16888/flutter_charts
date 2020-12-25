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
import '../numeric_extents.dart' show NumericExtents;
import '../../../../common/date_time_factory.dart' show DateTimeFactory;
import '../scale.dart' show Extents;

class DateTimeExtents extends Extents<DateTime> {
  final DateTime start;
  final DateTime end;
  final NumericExtents extents;
  final DateTimeFactory dateTimeFactory;

  DateTimeExtents({@required this.start, @required this.end, this.extents, this.dateTimeFactory});

  @override
  bool operator ==(other) {
    return other is DateTimeExtents && start == other.start && end == other.end;
  }

  @override
  int get hashCode => (start.hashCode + (end.hashCode * 37));

  DateTime middle({bool isDay = false}) {
    return _getDateTime(extents.middle.toInt(), isDay, true, false, false);
  }

  DateTime middleLeft({bool isDay = false}) {
    return _getDateTime(extents.middleLeft.toInt(), isDay, false, true, false);
  }

  DateTime middleRight({bool isDay = false}) {
    return _getDateTime(extents.middleRight.toInt(), isDay, false, false, true);
  }

  DateTime _getDateTime(int milliSeconds, bool isDay, bool isMiddle, bool isMiddleLeft, bool isMiddleRight) {
    var dateTime = dateTimeFactory.createDateTimeFromMilliSecondsSinceEpoch(milliSeconds);
    if (isDay) {
      var days = 0;
      if (isMiddle) {
        days = dateTime.hour > 12 ? 1 : 0;
      } else if (isMiddleLeft) {
        days = 1;
      } else if (isMiddleRight) {
        days = 0;
      }
      dateTime = dateTime.add(Duration(days: days, hours: -dateTime.hour, minutes: -dateTime.minute, seconds: -dateTime.second, milliseconds: -dateTime.millisecond, microseconds: -dateTime.microsecond));
    }
    return dateTime;
  }
}
