package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/path_provider"
	"github.com/nealwon/go-flutter-plugin-sqlite"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 800),
	flutter.ForcePixelRatio(1.0),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
    	VendorName:      "sudoku.ColaTea.com",
    	ApplicationName: "sudoku",
    }),
    flutter.AddPlugin(sqflite.NewSqflitePlugin("sudoku.ColaTea.com","sudoku")),
}
