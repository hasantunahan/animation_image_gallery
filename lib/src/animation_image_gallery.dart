import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'image_item_model.dart';


class AnimatedSizeImage extends StatefulWidget {
  final List<ImageItemModel> imageList;
  const AnimatedSizeImage({Key? key, required this.imageList}) : super(key: key);

  @override
  State<AnimatedSizeImage> createState() => _AnimatedSizeImageState();
}

class _AnimatedSizeImageState extends State<AnimatedSizeImage> {
  final ItemScrollController _scrollController = ItemScrollController();

  late String imageUrl = widget.imageList[mIndex].url;
  int mIndex = 0;
  int nextIndex = 1;
  double height = 0;
  bool isOpen = false;
  Alignment alignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        isOpen = true;
        height = MediaQuery.of(context).size.width;
      });
    });
  }

  void updateImageUrl(int index, bool nextIsRight) {
    setState(() {
      alignment = nextIsRight ? Alignment.centerLeft : Alignment.centerRight;
      height = 0;
      isOpen = false;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        imageUrl = widget.imageList[index].url;
        isOpen = true;
        mIndex = index;
        height = MediaQuery.of(context).size.width;
      });
    });
    _scrollController.scrollTo(index: index, duration: const Duration(milliseconds: 300));
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        nextIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.imageList[nextIndex].url),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if ((details.primaryVelocity ?? 0) > 0) {
                    if (mIndex > 0) {
                      updateImageUrl(mIndex - 1, false);
                    }
                  } else if ((details.primaryVelocity ?? 0) < 0) {
                    if ((mIndex + 1) < widget.imageList.length) {
                      updateImageUrl(mIndex + 1, true);
                    }
                  }
                },
                child: Align(
                  alignment: alignment,
                  child: AnimatedContainer(
                    height: double.infinity,
                    width: height,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isOpen ? 1 : 0.8,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).padding.bottom),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    color: Colors.white12,
                    height: 80,
                    child: ScrollablePositionedList.builder(
                      itemScrollController: _scrollController,
                      itemCount: widget.imageList.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => updateImageUrl(index, index < mIndex ? false : true),
                          child: Container(
                            height: 70,
                            width: 70,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.white,
                                border: Border.all(color: index == mIndex ? Colors.orange : Colors.white12, width: 3)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.network(
                                  widget.imageList[index].url,
                                  fit: BoxFit.fill,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
