import 'package:flutter/material.dart';

class InstagramGrid extends StatelessWidget {
  InstagramGrid({super.key});

  // サンプルのアスペクト比（横:縦）
  final List<double> aspectRatios = [
    1.0, // 正方形
    4 / 3, // 横長
    3 / 4, // 縦長
    1.0, // 正方形
    4 / 3,
    3 / 4,
    1.0,
    4 / 3,
    3 / 4,
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            // 3列の固定幅を設定しつつ、動的に高さを調整
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  MediaQuery.of(context).size.width / 3, // 3列の幅を固定
              mainAxisSpacing: 2, // 縦の間隔
              crossAxisSpacing: 2, // 横の間隔
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final aspectRatio = aspectRatios[index % aspectRatios.length];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // 3列の幅に基づいて高さを計算
                    final width = constraints.maxWidth;
                    final height = width / aspectRatio;
                    return Container(
                      color: Colors.grey[300], // 背景色
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ここに実際の画像を表示する。サンプルではプレースホルダーとしてTextを表示
                          Center(
                            child: Text(
                              'Photo ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              childCount: 30, // 表示する写真の数
            ),
          ),
        ),
      ],
    );
  }
}
