import 'dart:math';
import 'dart:math' as math;

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import 'color_pic_btn.dart';
import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';
import 'painter.dart';

//icon changing
/// 默认工具栏构建器
/*typedef DefaultToolsBuilder = List<DefToolItem> Function(
  Type currType,
  DrawingController controller,
);*/

class CounterNotifier extends ValueNotifier<bool> {
  CounterNotifier({bool? value}) : super(value ?? false);

  void change() {
    value = !value;
  }

  void show() {
    value = true;
  }

  void hide() {
    value = false;
  }
}

class CheckState extends ValueNotifier<bool> {
  CheckState({bool? value}) : super(value ?? false);

  void state() {
    value = !value;
  }
}

/// 画板
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    Key? key,
    required this.background,
    this.controller,
    this.showDefaultActions1 = false,
    this.showDefaultActions2 = false,
    this.showDefaultActions3 = false,
    this.showDefaultActions4 = false,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    //this.defaultToolsBuilder,
    this.boardClipBehavior = Clip.hardEdge,
    this.panAxis = PanAxis.free,
    this.boardBoundaryMargin,
    this.boardConstrained = false,
    this.maxScale = 20,
    this.minScale = 1,
    //this.boardPanEnabled = true,
    //this.boardScaleEnabled = true,
    this.boardScaleFactor = 200.0,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.transformationController,
    this.alignment = Alignment.bottomCenter,
  }) : super(key: key);

  /// 画板背景控件
  final Widget background;

  /// 画板控制器
  final DrawingController? controller;

  /// 显示默认样式的操作栏
  final bool showDefaultActions;

  final bool showDefaultActions1;

  final bool showDefaultActions2;

  final bool showDefaultActions3;

  final bool showDefaultActions4;

  /// 显示默认样式的工具栏
  final bool showDefaultTools;

  /// 开始拖动
  final Function(PointerDownEvent pde)? onPointerDown;

  /// 正在拖动
  final Function(PointerMoveEvent pme)? onPointerMove;

  /// 结束拖动
  final Function(PointerUpEvent pue)? onPointerUp;

  /// 边缘裁剪方式
  final Clip clipBehavior;

  /// 默认工具栏构建器
  //final DefaultToolsBuilder? defaultToolsBuilder;

  /// 缩放板属性
  final Clip boardClipBehavior;
  final PanAxis panAxis;
  final EdgeInsets? boardBoundaryMargin;
  final bool boardConstrained;
  final double maxScale;
  final double minScale;
  final void Function(ScaleEndDetails)? onInteractionEnd;
  final void Function(ScaleStartDetails)? onInteractionStart;
  final void Function(ScaleUpdateDetails)? onInteractionUpdate;
  //final bool boardPanEnabled;
  // final bool boardScaleEnabled;
  final double boardScaleFactor;
  final TransformationController? transformationController;
  final AlignmentGeometry alignment;

  //final ValueNotifier<bool> _counter = ValueNotifier<bool>(false);

  /// 默认工具项列表
  /*static List<DefToolItem> defaultTools(
          Type currType, DrawingController controller) =>
      <DefToolItem>[
        DefToolItem(
          isActive: currType == SimpleLine,
          icon: CupertinoIcons.pencil,
          onTap: () {
            controller.setPaintContent = SimpleLine();
          },
        ),
        DefToolItem(
          isActive: currType == SmoothLine,
          icon: Icons.brush,
          onTap: () => controller.setPaintContent = SmoothLine(),
        ),
        DefToolItem(
          isActive: currType == StraightLine,
          icon: Icons.show_chart,
          onTap: () => controller.setPaintContent = StraightLine(),
        ),
        /*DefToolItem(
          isActive: currType == Rectangle,
          icon: CupertinoIcons.stop,
          onTap: () => controller.setPaintContent = Rectangle()),
      DefToolItem(
          isActive: currType == Circle,
          icon: CupertinoIcons.circle,
          onTap: () => controller.setPaintContent = Circle()),*/
        DefToolItem(
          isActive: currType == Eraser,
          icon: CupertinoIcons.bandage,
          onTap: () => controller.setPaintContent = Eraser(color: Colors.white),
        ),
      ];*/

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();

  void setState(Null Function() param0) {}
}

double screenHeight = 0;

class _DrawingBoardState extends State<DrawingBoard>
    with TickerProviderStateMixin {
  late final DrawingController _controller =
      widget.controller ?? DrawingController();
  TransformationController _transformationController =
      TransformationController();
  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;
  int value = 0;
  bool positive = false;
  bool loading = false;
  // bool selected = false;
  int tap1 = 0;
  int tap2 = 0;
  int tap3 = 0;
  int tap4 = 0;
  Color black = Colors.black;
  Color blue = Colors.blue;

  CounterNotifier change = CounterNotifier();
  CounterNotifier change2 = CounterNotifier();
  CounterNotifier change3 = CounterNotifier();
  CounterNotifier change4 = CounterNotifier();
  CounterNotifier changeMode = CounterNotifier();

  CheckState checking = CheckState();
  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..translate(0.0, screenHeight * 0.1),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _controllerReset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(Matrix4.identity());
    screenHeight = MediaQuery.of(context).size.height;
    Widget content = InteractiveViewer(
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      boundaryMargin: widget.boardBoundaryMargin ??
          EdgeInsets.all(MediaQuery.of(context).size.width),
      clipBehavior: widget.boardClipBehavior,
      panAxis: widget.panAxis,
      constrained: widget.boardConstrained,
      onInteractionStart: _onInteractionStart,
      onInteractionUpdate: widget.onInteractionUpdate,
      onInteractionEnd: widget.onInteractionEnd,
      scaleFactor: widget.boardScaleFactor,
      panEnabled: !changeMode.value, //widget.boardPanEnabled,
      scaleEnabled: !changeMode.value, //widget.boardScaleEnabled,
      transformationController: _transformationController =
          TransformationController(
        Matrix4.identity()..translate(0.0, screenHeight * 0.1),
      ),
      child: Container(
        //그림판 가운데 정렬
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: _buildBoard,
      ),
    );

    if (widget.showDefaultActions ||
        widget.showDefaultActions1 ||
        widget.showDefaultTools ||
        widget.showDefaultActions2 ||
        widget.showDefaultActions3 ||
        widget.showDefaultActions4) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (widget.showDefaultActions) _uppermenu,
            ],
          ),
          Expanded(child: content),
          if (widget.showDefaultActions1) _slider,
          if (widget.showDefaultActions2) _slider2,
          if (widget.showDefaultActions3) _slider3,
          if (widget.showDefaultActions4) _slider4,

          //if (widget.showDefaultActions) _uppermenu,
          if (widget.showDefaultTools) _buildDefaultTools,
          if (widget.showDefaultActions) _togglebutton,
        ],
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent pde) =>
          _controller.addFingerCount(pde.localPosition),
      onPointerUp: (PointerUpEvent pue) =>
          _controller.reduceFingerCount(pue.localPosition),
      child: content,
    );
  }

  /// 构建画板
  Widget get _buildBoard {
    return RepaintBoundary(
      key: _controller.painterKey,
      child: ExValueBuilder<DrawConfig>(
        valueListenable: _controller.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) =>
            p.angle != n.angle || p.size != n.size,
        builder: (_, DrawConfig dc, Widget? child) {
          Widget c = child!;

          if (dc.size != null) {
            final bool isHorizontal = dc.angle.toDouble() % 2 == 0;
            final double max = dc.size!.longestSide;

            if (!isHorizontal) {
              c = SizedBox(
                width: max,
                height: max,
                child: c,
              );
            }
          }

          return Transform.rotate(
            angle: dc.angle * pi / 2,
            child: c,
          );
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[_buildImage, _buildPainter],
          ),
        ),
      ),
    );
  }

  /// background
  Widget get _buildImage => GetSize(
        onChange: (Size? size) => _controller.setBoardSize(size),
        child: widget.background,
      );

  /// Make layer
  Widget get _buildPainter {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.size != n.size,
      builder: (_, DrawConfig dc, Widget? child) {
        return SizedBox(
          width: dc.size?.width,
          height: dc.size?.height,
          child: child,
        );
      },
      child: Painter(
        drawingController: _controller,
        onPointerDown: widget.onPointerDown,
        onPointerMove: widget.onPointerMove,
        onPointerUp: widget.onPointerUp,
      ),
    );
  }

  /// 构建默认操作栏
  ///  작업표시줄

  Widget get _slider {
    return ValueListenableBuilder(
      valueListenable: change,
      builder: (BuildContext context, Object? value, Widget? child) {
        return Visibility(
          visible: change.value,
          //   replacement: ,
          child: Material(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  ExValueBuilder<DrawConfig>(
                    valueListenable: _controller.drawConfig,
                    shouldRebuild: (DrawConfig p, DrawConfig n) =>
                        p.strokeWidth != n.strokeWidth,
                    builder: (_, DrawConfig dc, ___) {
                      return Slider(
                        value: dc.strokeWidth,
                        max: 50,
                        min: 1,
                        onChanged: (double v) =>
                            _controller.setStyle(strokeWidth: v),
                      );
                    },
                  ),
                  ColorPicBtn(controller: _controller),
                  /*IconButton(
                  icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: const Icon(UniconsLine.redo)),
                  onPressed: () => _controller.undo(),
                ),
                IconButton(
                  icon: const Icon(UniconsLine.redo),
                  onPressed: () => _controller.redo(),
                ),
                /*IconButton(
                    icon: const Icon(UniconsLine.corner_up_right),
                    onPressed: () => _controller.turn()),*/
                IconButton(
                  icon: const Icon(UniconsLine.trash_alt),
                  onPressed: () => _controller.clear(),
                ),*/
                  /*AnimatedToggleSwitch<bool>.dual(
                  current: positive,
                  first: false,
                  second: true,
                  dif: 10.0,
                  borderColor: Colors.transparent,
                  borderWidth: 5.0,
                  height: 30,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                  onChanged: (bool b) {
                    setState(() => positive = b);
                  },
                  colorBuilder: (bool b) => b ? Colors.red : Colors.green,
                  iconBuilder: (bool value) => value
                      ? const Icon(Icons.coronavirus_rounded)
                      : const Icon(Icons.tag_faces_rounded),
                  textBuilder: (bool value) => value
                      ? const Center(child: Text('TEST2'))
                      : const Center(child: Text('TEST1')),
                ),
                IconButton(
                  onPressed: _animateResetInitialize,
                  tooltip: 'Reset',
                  color: Theme.of(context).colorScheme.surface,
                  icon: const Icon(
                    Icons.replay,
                    color: Colors.black,
                  ),
                ),*/
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _slider2 {
    return ValueListenableBuilder(
      valueListenable: change2,
      builder: (BuildContext context, Object? value, Widget? child) {
        return Visibility(
          visible: change2.value,
          //   replacement: ,
          child: Material(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  ExValueBuilder<DrawConfig>(
                    valueListenable: _controller.drawConfig,
                    shouldRebuild: (DrawConfig p, DrawConfig n) =>
                        p.strokeWidth != n.strokeWidth,
                    builder: (_, DrawConfig dc, ___) {
                      return Slider(
                        value: dc.strokeWidth,
                        max: 50,
                        min: 1,
                        onChanged: (double v) =>
                            _controller.setStyle(strokeWidth: v),
                      );
                    },
                  ),
                  ColorPicBtn(controller: _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _slider3 {
    return ValueListenableBuilder(
      valueListenable: change3,
      builder: (BuildContext context, Object? value, Widget? child) {
        return Visibility(
          visible: change3.value,
          //   replacement: ,
          child: Material(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  ExValueBuilder<DrawConfig>(
                    valueListenable: _controller.drawConfig,
                    shouldRebuild: (DrawConfig p, DrawConfig n) =>
                        p.strokeWidth != n.strokeWidth,
                    builder: (_, DrawConfig dc, ___) {
                      return Slider(
                        value: dc.strokeWidth,
                        max: 50,
                        min: 1,
                        onChanged: (double v) =>
                            _controller.setStyle(strokeWidth: v),
                      );
                    },
                  ),
                  ColorPicBtn(controller: _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _slider4 {
    return ValueListenableBuilder(
      valueListenable: change4,
      builder: (BuildContext context, Object? value, Widget? child) {
        return Visibility(
          visible: change4.value,
          //   replacement: ,
          child: Material(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  ExValueBuilder<DrawConfig>(
                    valueListenable: _controller.drawConfig,
                    shouldRebuild: (DrawConfig p, DrawConfig n) =>
                        p.strokeWidth != n.strokeWidth,
                    builder: (_, DrawConfig dc, ___) {
                      return Slider(
                        value: dc.strokeWidth,
                        max: 50,
                        min: 1,
                        onChanged: (double v) =>
                            _controller.setStyle(strokeWidth: v),
                      );
                    },
                  ),
                  //ColorPicBtn(controller: _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _uppermenu {
    return Material(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: const Icon(UniconsLine.redo)),
              onPressed: () => _controller.undo(),
            ),
            IconButton(
              icon: const Icon(UniconsLine.redo),
              onPressed: () => _controller.redo(),
            ),
            /*IconButton(
                icon: const Icon(UniconsLine.corner_up_right),
                onPressed: () => _controller.turn()),*/
            IconButton(
              icon: const Icon(UniconsLine.trash_alt),
              onPressed: () => _controller.clear(),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _togglebutton {
    return Material(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            AnimatedToggleSwitch<bool>.dual(
              current: positive,
              first: false,
              second: true,
              dif: 10.0,
              borderColor: Colors.transparent,
              borderWidth: 5.0,
              height: 30,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1.5),
                ),
              ],
              onChanged: (bool b) {
                setState(() => positive = b);
                changeMode.change();
              },
              colorBuilder: (bool b) => b ? Colors.red : Colors.green,
              iconBuilder: (bool value) => value
                  ? const Icon(Icons.coronavirus_rounded) //오른쪽
                  : const Icon(Icons.tag_faces_rounded), //왼쪽
              textBuilder: (bool value) => value
                  ? const Center(child: Text('TEST2'))
                  : const Center(child: Text('TEST1')),
            ),
            IconButton(
              onPressed: _animateResetInitialize,
              tooltip: 'Reset',
              color: Theme.of(context).colorScheme.surface,
              icon: const Icon(
                Icons.replay,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 도구
  Widget get _buildDefaultTools {
    return Material(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            /*GestureDetector(
              onTap: () {
                change.hide();
                //change.show();
              },
              child: const Icon(Icons.pentagon),
            ),*/
            IconButton(
              icon: const Icon(
                Icons.pentagon,
              ),
              onPressed: () {
                change2.hide();
                change3.hide();
                change4.hide();
                change.change();
                _controller.setPaintContent = SimpleLine();
              },
            ),
            IconButton(
              icon: const Icon(Icons.abc),
              onPressed: () {
                change.hide();
                change3.hide();
                change4.hide();
                change2.change();
                _controller.setPaintContent = SmoothLine();
              },
            ),
            IconButton(
              icon: const Icon(Icons.abc),
              onPressed: () {
                change.hide();
                change2.hide();
                change4.hide();
                change3.change();
                _controller.setPaintContent = StraightLine();
              },
            ),
            IconButton(
              icon: const Icon(Icons.abc),
              onPressed: () {
                change.hide();
                change2.hide();
                change3.hide();
                change4.change();
                _controller.setPaintContent = Eraser(color: Colors.white);
              },
            ),
          ],
        ), /*ExValueBuilder<DrawConfig>(
          valueListenable: _controller.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) =>
              p.contentType != n.contentType,
          builder: (_, DrawConfig dc, ___) {
            final Type currType = dc.contentType;
    
            return Row(
              children:
                  (widget.defaultToolsBuilder?.call(currType, _controller) ??
                          DrawingBoard.defaultTools(currType, _controller))
                      .map((DefToolItem item) => _DefToolItemWidget(item: item))
                      .toList(),
            );
          },
        ),*/
      ),
    );
  }
}

/// 기본 도구 설정
/*class DefToolItem extends StatefulWidget {
  DefToolItem({
    required this.icon,
    required this.isActive,
    this.onTap,
    this.color,
    this.activeColor = const Color.fromARGB(255, 18, 250, 219),
    this.iconSize,
    this.setState,
  });

  final Function()? onTap;
  final Function()? setState;
  final bool isActive;

  final IconData icon;
  final double? iconSize;
  final Color? color;
  final Color activeColor;
  final ValueNotifier<bool> _counter = ValueNotifier<bool>(false);

  @override
  _DefToolItemWidgetState createState() => _DefToolItemWidgetState();
}

/// 默认工具项 Widget
class _DefToolItemWidget extends StatefulWidget {
  const _DefToolItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final DefToolItem item;

  @override
  State<_DefToolItemWidget> createState() => _DefToolItemWidgetState();
}

class _DefToolItemWidgetState extends State<_DefToolItemWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.item.onTap,
      icon: Icon(
        widget.item.icon,
        color:
            widget.item.isActive ? widget.item.activeColor : widget.item.color,
        size: widget.item.iconSize,
      ),
    );
  }
}*/
