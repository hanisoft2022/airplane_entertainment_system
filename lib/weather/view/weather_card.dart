import 'package:airplane_entertainment_system/generated/assets.gen.dart';
import 'package:airplane_entertainment_system/l10n/arb/app_localizations.dart';
import 'package:airplane_entertainment_system/l10n/l10n.dart';
import 'package:airplane_entertainment_system/weather/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      height: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state.status == WeatherStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == WeatherStatus.error) {
              return Center(
                child: Text(
                  l10n.weatherErrorMessage,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _WeatherDetails(
                      temperature: state.weatherInfo!.temperature.toString(),
                      label: state.weatherInfo!.conditionLabel(l10n),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: _WeatherIllustration(
                          key: ValueKey(state.weatherInfo!.condition),
                          gradient: state.weatherInfo!.gradient,
                          imageAsset: state.weatherInfo!.imageAsset,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeatherDetails extends StatelessWidget {
  const _WeatherDetails({
    required this.temperature,
    required this.label,
  });

  final String temperature;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Text(
            '$temperature°',
            style: const TextStyle(
              fontSize: 60,
              height: 0.8,
            ),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
          ),
        ),
      ],
    );
  }
}

class _WeatherIllustration extends StatelessWidget {
  const _WeatherIllustration({
    required this.gradient,
    required this.imageAsset,
    super.key,
  });

  final AssetGenImage imageAsset;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: imageAsset.image(),
        ),
      ],
    );
  }
}

const _clearWeatherGradient = [
  Color.fromARGB(255, 17, 204, 251),
  Color.fromARGB(255, 151, 210, 255),
];

const _cloudyWeatherGradient = [
  Color.fromARGB(255, 48, 137, 209),
  Color.fromARGB(255, 152, 201, 239),
];

const _rainyWeatherGradient = [
  Color.fromARGB(255, 92, 134, 169),
  Color.fromARGB(255, 170, 205, 233),
];

const _thunderstormsWeatherGradient = [
  Color.fromARGB(255, 53, 76, 95),
  Color.fromARGB(255, 179, 193, 203),
];

@visibleForTesting
extension WeatherUI on WeatherInformation {
  String conditionLabel(AppLocalizations l10n) {
    return switch (condition) {
      WeatherCondition.clear => l10n.clear,
      WeatherCondition.cloudy => l10n.cloudy,
      WeatherCondition.rainy => l10n.rainy,
      WeatherCondition.thunderstorms => l10n.thunderstorms,
    };
  }

  AssetGenImage get imageAsset {
    return switch (condition) {
      WeatherCondition.clear => Assets.weather.clear,
      WeatherCondition.cloudy => Assets.weather.cloudy,
      WeatherCondition.rainy => Assets.weather.rainy,
      WeatherCondition.thunderstorms => Assets.weather.thunderstorms,
    };
  }

  List<Color> get gradient {
    return switch (condition) {
      WeatherCondition.clear => _clearWeatherGradient,
      WeatherCondition.cloudy => _cloudyWeatherGradient,
      WeatherCondition.rainy => _rainyWeatherGradient,
      WeatherCondition.thunderstorms => _thunderstormsWeatherGradient,
    };
  }
}
