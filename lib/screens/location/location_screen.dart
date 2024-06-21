import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;

import '../../blocs/blocs.dart';
import '../../widgets/widgets.dart';

class LocationScreen extends StatefulWidget {
  static const String routeName = '/location';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => LocationScreen(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Platform.isAndroid && state == AppLifecycleState.resumed) {
      setState(() {
        forceReRender();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> forceReRender() async {
    await _mapController?.setMapStyle('[]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is LocationLoaded) {
            Set<Marker> markers = state.restaurants!.map((restaurant) {
              return Marker(
                markerId: MarkerId(restaurant.id),
                infoWindow: InfoWindow(
                  title: restaurant.name,
                  snippet: restaurant.description,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/restaurant-details',
                      arguments: restaurant,
                    );
                  },
                ),
                position: LatLng(
                  restaurant.address.lat.toDouble(),
                  restaurant.address.lon.toDouble(),
                ),
              );
            }).toSet();

            return Stack(
              children: [
                // GoogleMap(
                //   myLocationEnabled: true,
                //   buildingsEnabled: false,
                //   onMapCreated: (GoogleMapController controller) {
                //     context.read<LocationBloc>().add(
                //           LoadMap(controller: controller),
                //         );
                //   },
                //   markers: markers,
                //   initialCameraPosition: CameraPosition(
                //     target: LatLng(
                //       state.place.lat.toDouble(),
                //       state.place.lon.toDouble(),
                //     ),
                //     zoom: 15,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/logo.svg', height: 50),
                          SizedBox(width: 10),
                          Expanded(child: LocationSearchBox()),
                        ],
                      ),
                      // _SearchBoxSuggestions(),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          fixedSize: Size(200, 40),
                        ),
                        child:
                            Text('NEXT', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                        onPressed: () {
                          print(state.place);
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Text('Something went wrong!');
          }
        },
      ),
    );
  }
}

class _SearchBoxSuggestions extends StatelessWidget {
  const _SearchBoxSuggestions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutocompleteBloc, AutocompleteState>(
      builder: (context, state) {
        if (state is AutocompleteLoading) {
          return SizedBox();
        }
        if (state is AutocompleteLoaded) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: state.autocomplete.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.black.withOpacity(0.6),
                child: ListTile(
                  title: Text(
                    state.autocomplete[index].description,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  ),
                  onTap: () {
                    context.read<LocationBloc>().add(
                          SearchLocation(
                            placeId: state.autocomplete[index].placeId,
                          ),
                        );
                    context.read<AutocompleteBloc>().add(ClearAutocomplete());
                  },
                ),
              );
            },
          );
        } else {
          return Text('Something went wrong!');
        }
      },
    );
  }
}
