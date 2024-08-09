import 'package:flutter/material.dart';
import 'package:zonetwo/utils/functions/format_datetime.dart';
import '../entities/workout_entity.dart';

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({
    required this.workout,
    super.key,
    this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  final WorkoutEntity workout;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
        key: Key('todoListTile_${workout.id}'),
        child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListTile(
                      title: Text(
                        formatDatetime(workout.datetime),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      ),
                      leading: const Icon(Icons.run_circle_outlined),
                      textColor: theme.textTheme.bodySmall?.color,
                      subtitle: Text(
                        "${formatDuration(workout.duration)}\t\t${workout.distance.toStringAsFixed(2)}km",
                      )),
                ),
                isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (bool? x) {
                          onTap!();
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            )));
  }
}
