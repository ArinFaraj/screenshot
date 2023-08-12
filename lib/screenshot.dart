library screenshot;

// import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
//import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
<<<<<<< HEAD
import 'package:image/image.dart' as imagePkg;
=======
>>>>>>> ae826081dc7e026b19763f2a53fac9bce956e15c

import 'src/platform_specific/file_manager/file_manager.dart';

///
///
///Cannot capture Platformview due to issue https://github.com/flutter/flutter/issues/25306
///
///
class ScreenshotController {
  late GlobalKey _containerKey;

  ScreenshotController() {
    _containerKey = GlobalKey();
  }

  /// Captures image and saves to given path
  Future<String?> captureAndSave(
    String directory, {
    String? fileName,
    double? pixelRatio,
    Duration delay = const Duration(milliseconds: 20),
  }) async {
    Uint8List? content = await capture(
      pixelRatio: pixelRatio,
      delay: delay,
    );
    PlatformFileManager fileManager = PlatformFileManager();

    return fileManager.saveFile(content!, directory, name: fileName);
  }

  Future<Uint8List?> capture({
    double? pixelRatio,
    Duration delay = const Duration(milliseconds: 20),
  }) {
    //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    return new Future.delayed(delay, () async {
      try {
        ui.Image? image = await captureAsUiImage(
          delay: Duration.zero,
          pixelRatio: pixelRatio,
        );
        ByteData? byteData = 
        await image?.toByteData(format: ui.ImageByteFormat.rawRgba);
        image?.dispose();

        Uint8List? pngBytes = byteData?.buffer.asUint8List();

        var receivePort = ReceivePort();

        await Isolate.spawn(
            decodeIsolate,
            DecodeParam(byteData!, image!.width.floor(), image.height.floor(),
                receivePort.sendPort));

        var imagwe = await receivePort.first as Uint8List;

        return imagwe;
      } catch (Exception) {
        throw (Exception);
      }
    });
  }

  Future<ui.Image?> captureAsUiImage(
      {double? pixelRatio = 1,
      Duration delay = const Duration(milliseconds: 20)}) {
    //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    return new Future.delayed(delay, () async {
      try {
        var findRenderObject =
            this._containerKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        BuildContext? context = _containerKey.currentContext;
        if (pixelRatio == null) {
          if (context != null)
            pixelRatio = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
        }
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);
        return image;
      } catch (Exception) {
        throw (Exception);
      }
    });
  }

  ///
  /// Value for [delay] should increase with widget tree size. Prefered value is 1 seconds
  ///
  ///[context] parameter is used to Inherit App Theme and MediaQuery data.
  ///
  ///
  ///
  Future<Uint8List> captureFromWidget(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    ui.Image image = await widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize);
    // converts to jpg format
    final ByteData? byteData =
<<<<<<< HEAD
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
=======
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
>>>>>>> ae826081dc7e026b19763f2a53fac9bce956e15c

    var receivePort = ReceivePort();

    await Isolate.spawn(
        decodeIsolate,
        DecodeParam(byteData!, image.width.floor(), image.height.floor(),
            receivePort.sendPort));

    var imagwe = await receivePort.first as Uint8List;

    return imagwe;
  }

<<<<<<< HEAD
=======
  /// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
>>>>>>> ae826081dc7e026b19763f2a53fac9bce956e15c
  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    ///
    ///Retry counter
    ///
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///
      ///Inherit Theme and MediaQuery of app
      ///
      ///
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              child: child,
              color: Colors.transparent,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
<<<<<<< HEAD

    Size logicalSize = targetSize ??
        ui.window.physicalSize / ui.window.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? ui.window.physicalSize; // Adapted
=======
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view =
        context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    Size logicalSize =
        targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? view.physicalSize; // Adapted
>>>>>>> ae826081dc7e026b19763f2a53fac9bce956e15c

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///
          ///current render is dirty, mark it.
          ///
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child,
            )).attachToRenderTree(
      buildOwner,
    );
    ////
    ///Render Widget
    ///
    ///

    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      ///
      ///Reset the dirty flag
      ///
      ///
      isDirty = false;

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///
      ///This delay sholud increas with Widget tree Size
      ///

      await Future.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      if (isDirty) {
        ///
        ///Previous capture has been updated, re-render again.
        ///
        ///
        buildOwner.buildScope(
          rootElement,
        );
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;

      ///
      ///retry untill capture is successfull
      ///
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      // rootElement.visitChildren((Element element) {
      //   rootElement.deactivateChild(element);
      // });
      buildOwner.finalizeTree();
    } catch (e) {}

<<<<<<< HEAD
    return image;
  }
}

class DecodeParam {
  final ByteData file;
  final int width;
  final int height;
  final SendPort sendPort;

  DecodeParam(
    this.file,
    this.width,
    this.height,
    this.sendPort,
  );
}

void decodeIsolate(DecodeParam param) {
  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  final imagee = imagePkg.Image.fromBytes(
    width: param.width.floor(),
    height: param.height.floor(),
    bytes: param.file.buffer,
    numChannels: 4,
    order: imagePkg.ChannelOrder.rgba,
  );
  // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
  Uint8List thumbnail = imagePkg.encodeJpg(imagee, quality: 100);
  param.sendPort.send(thumbnail);
}

class Screenshot<T> extends StatefulWidget {
=======
    return image; // Adapted to directly return the image and not the Uint8List
  }

  ///
  /// ### This function will calculate the size of your widget and then captures it.
  ///
  /// ## Notes on Usage:
  ///     1. Do not use any scrolling widgets like ListView,GridView. Convert those widgets to use Columns and Rows.
  ///     2. Do not Widgets like `Flexible`,`Expanded`, or `Spacer`. If you do Please consider passing constraints.
  /// 
  /// Params:
  ///
  /// [widget] : The Widget which needs to be captured.
  ///
  /// [delay] : Value for [delay] should increase with widget tree size. Preferred value is 1 seconds
  ///
  /// [context] : parameter is used to Inherit App Theme and MediaQuery data.
  ///
  /// [constraints] : Constraints for your image. Pass this parameter if your widget contains `Scaffold`,`Expanded`,`Flexible`,`Spacer` or any other widget which needs constraint of parent.
  ///
  ///
  ///
  Future<Uint8List> captureFromLongWidget(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    BoxConstraints? constraints,
  }) async {
    ui.Image image = await longWidgetToUiImage(
      widget,
      delay: delay,
      pixelRatio: pixelRatio,
      context: context,
      constraints: constraints ?? BoxConstraints(),
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> longWidgetToUiImage(Widget widget,
      {Duration delay = const Duration(seconds: 1),
      double? pixelRatio,
      BuildContext? context,
      BoxConstraints constraints = const BoxConstraints(
        maxHeight: double.maxFinite,
      )}) async {
    final PipelineOwner pipelineOwner = PipelineOwner();
    final _MeasurementView rootView =
        pipelineOwner.rootNode = _MeasurementView(constraints);
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> element =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: 'root_render_element_for_size_measurement',
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);
    try {
      rootView.scheduleInitialLayout();
      pipelineOwner.flushLayout();

      ///
      /// Calculate Size, and capture widget.
      ///

      return widgetToUiImage(
        widget,
        targetSize: rootView.size,
        context: context,
        delay: delay,
        pixelRatio: pixelRatio,
      );
    } finally {
      // Clean up.
      element
          .update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
      buildOwner.finalizeTree();
    }
  }
}

class Screenshot extends StatefulWidget {
>>>>>>> ae826081dc7e026b19763f2a53fac9bce956e15c
  final Widget? child;
  final ScreenshotController controller;

  const Screenshot({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  State<Screenshot> createState() {
    return new ScreenshotState();
  }
}

class ScreenshotState extends State<Screenshot> with TickerProviderStateMixin {
  late ScreenshotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller._containerKey,
      child: widget.child,
    );
  }
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

///
/// RenderBox widget to calculate size.
///
class _MeasurementView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  final BoxConstraints boxConstraints;
  _MeasurementView(this.boxConstraints);

  @override
  void performLayout() {
    assert(child != null);
    child!.layout(boxConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
