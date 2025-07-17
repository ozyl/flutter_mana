import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import '../utils/page_info_helper.dart';

class ShowCodeContent extends StatelessWidget {
  final HighlighterTheme theme;

  const ShowCodeContent({super.key, required this.theme});

  // 统一的字体大小
  static const double _fontSize = 12.0;
  // 分割线颜色
  static final Color _dividerColor = Colors.grey.shade200;

  @override
  Widget build(BuildContext context) {
    final pageInfoHelper = PageInfoHelper();

    final filePath = pageInfoHelper.packagePathConvertFromFilePath(pageInfoHelper.filePath);

    final highlighter = Highlighter(
      language: 'dart',
      theme: theme,
    );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: _dividerColor),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              filePath,
              style: TextStyle(
                fontSize: _fontSize,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: _dividerColor),
          FutureBuilder(
            future: pageInfoHelper.getCode(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                return SizedBox.shrink();
              }
              if (snapshot.data == null) {
                return SizedBox.shrink();
              }

              return Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      child: SelectableText.rich(
                        highlighter.highlight(snapshot.data!),
                        style: TextStyle(fontSize: _fontSize),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
