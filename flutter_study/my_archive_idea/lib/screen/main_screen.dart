import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:my_archive_idea/database/database_helper.dart';

import '../data/idea_info.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var dbHelper = DatabaseHelper(); // 데이터베이스 접근을 용이하게 해주는 유틸 객체
  List<IdeaInfo> listIdeaInfo = []; // 아이디어 목록 데이터들이 담길 공간

  @override
  void initState() {
    super.initState();

    // 임시용 INSERT 데이터
    // setInsertIdeaInfo();

    // 아이디어 정보 가져오기
    getIdeaInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archive Idea',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: listIdeaInfo.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: listItem(index),
              onTap: () async {
                var result = await Navigator.pushNamed(context, '/detail', arguments: listIdeaInfo[index]);
                if (result != null) {
                  String msg = "";

                  if (result == 'update') {
                    // 수정 완료 (update)
                    msg = '아이디어가 수정되었습니다.';
                  } else if (result == 'delete') {
                    // 삭제 완료 (delete)
                    msg = '아이디어가 삭제되었습니다.';
                  }
                  // refresh list
                  getIdeaInfo();

                  // show snackBar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 새 아이디어 작성 화면으로 이동
          var result = await Navigator.pushNamed(context, '/edit');

          // A -> B -> A 화면으로 돌아 왔을 때(B로부터 결과값을 전달 받았을 떄)
          if (result != null) {
            // 아이디어 리스트 다시 불러오기
            getIdeaInfo();
            // 아이디어 작성이 완료되었다는 스낵바 메시지 띄우기
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('새로운 아이디어가 추가되었습니다.'),
                ),
              );
            }
          }
        },
        child: Image.asset(
          'assets/idea.png',
          width: 48,
          height: 48,
        ),
        backgroundColor: Colors.lightBlueAccent.withOpacity(0.7), // 투명도
      ),
    );
  }

  Widget listItem(index) {
    return Container(
      height: 82,
      margin: EdgeInsets.only(top: 16),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xffd9d9d9), width: 1),
        borderRadius: BorderRadius.circular(10),
      )),
      child: Stack(
        // column과 row는 서로가 서로에게 영향을 주지만 스택은 말그대로 쌓는 방식이기 때문에 그렇지 않다.(겹칠 수도 있음)
        alignment: Alignment.centerLeft,
        children: [
          // 아이디어 제목
          Container(
            margin: EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              listIdeaInfo[index].title,
              style: TextStyle(fontSize: 16),
            ),
          ),
          //일시
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(right: 16, bottom: 8),
              child: Text(
                DateFormat("yyyy.MM.dd HH:mm").format(
                    DateTime.fromMillisecondsSinceEpoch(
                        listIdeaInfo[index].createdAt)),
                style: TextStyle(color: Color(0xffaeaeae), fontSize: 10),
              ),
            ),
          ),
          //아이디어 중요도 점수(별)
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(left: 16, bottom: 8),
              child: RatingBar.builder(
                initialRating: listIdeaInfo[index].priority.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 16,
                itemPadding: EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                  );
                },
                ignoreGestures: true,
                updateOnDrag: false,
                onRatingUpdate: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getIdeaInfo() async {
    // idea 정보를 가져와서
    await dbHelper.initDatabase();
    // 멤버 (전역) 변수 리스트 객체에 담기
    listIdeaInfo = await dbHelper.getAllIdeaInfo();
    print('listInfoLength : ${listIdeaInfo.length}');
    // 리스트 객체 날짜 기준으로 역순 정렬하기(최신글 위로)
    listIdeaInfo.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    setState(() {}); // list 갱신으로 UI 업데이트
  }

  Future setInsertIdeaInfo() async {
    // 삽입하는 메서드
    await dbHelper.initDatabase();
    await dbHelper.insertIdeaInfo(
      IdeaInfo(
        title: '# 환경 보존 문제해결 앱 아이디어',
        motive: '길가자가 쓰레기 주우면서 깨달음',
        content: '자세한 내용입니다... 매우 자세한 내용',
        priority: 5,
        feedback: '피드백 사항입니다',
        createdAt: DateTime.now().millisecondsSinceEpoch, // 현재 시간
      ),
    );
  }
}
