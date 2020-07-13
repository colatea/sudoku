import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'config.dart';

class VersionInfo extends StatelessWidget {
  BuildContext _ctx;
  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Container(
//      color: Colors.lightGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _author(),
          _version(),
          _build(),
          _poweredby(),
        ],
      ),
    );
  }

  Widget _author() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Author", style: Theme.of(_ctx).textTheme.bodyText1,),
        Icon(Icons.person, color: Colors.pinkAccent, size: 16,),
        Text("${author}", style: Theme.of(_ctx).textTheme.bodyText2.copyWith(fontSize: 12),),
      ],
    );
  }

  Widget _version() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Version", style: Theme.of(_ctx).textTheme.bodyText1,),
        Icon(Icons.verified_user, color: Colors.lightGreen, size: 16,),
        Text("${version}", style: Theme.of(_ctx).textTheme.bodyText2.copyWith(fontSize: 12),),
      ],
    );
  }

  Widget _build() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Build", style: Theme.of(_ctx).textTheme.bodyText1,),
        Icon(Icons.build, color: Colors.indigoAccent, size: 16,),
        Text("${buildTime}", style: Theme.of(_ctx).textTheme.bodyText2.copyWith(fontSize: 12),),
      ],
    );
  }

  Widget _poweredby() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("PoweredBy", style: Theme.of(_ctx).textTheme.bodyText1,),
        Icon(Icons.mode_edit, color: Colors.blue, size: 16,),
        Text("${poweredBy}", style: Theme.of(_ctx).textTheme.bodyText2.copyWith(fontSize: 12),),
      ],
    );
  }
}

