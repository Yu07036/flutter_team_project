import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_team_project/design/insertForm.dart';

class boardPage extends StatefulWidget {
  const boardPage({Key? key}) : super(key: key);

  @override
  _boardPageState createState() => _boardPageState();
}

class _boardPageState extends State<boardPage> {

  var _lastRow = 0;
  final FETCH_ROW = 20;

  var stream;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    stream = newStream();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          stream = newStream();
        });
      }
    });
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('게시판')
        .orderBy("time", descending: true)
        .limit(FETCH_ROW * (_lastRow + 1))
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시판"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              //todo 네이게이터
              Navigator.push(
                  //네비게이터
                  context,
                  MaterialPageRoute(
                    //페이지 이동
                    builder: (context) => InsertForm(),
                  ));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator()); //로딩
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  final currentRow = (i + 1) ~/ FETCH_ROW;
                  if (_lastRow != currentRow) {
                    _lastRow = currentRow;
                  }
                  print("lastrow : " + _lastRow.toString());
                  return _buildListItem(context, snapshot.data!.docs[i]);
                },
              );
              // return ListView(
              //   children: snapshot.data!.docs
              //       .map((e) => _buildListItem(context, e))
              //       .toList(),
              // );
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            var count = 1;
            while (count < 120) {
              FirebaseFirestore.instance.collection('게시판').add({
                'content': '내용' + count.toString(),
                'time': FieldValue.serverTimestamp(),
                'title': '제목입니다' + count.toString(),
                'uid': '임시값',
                'writer': '임시작성자' + count.toString()
              });
              count = count + 1;
            }
          },
          label: Text('추가')),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  data['title'],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  data['writer'],
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  // get_item.insertTime.toString(),
                  data['time'].toString(),
                  // _DatePrint(data.isNoModify, insert_time, selected_item.datetime),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          onTap: () {
            //todo 네이게이터
          },
        ),
        Container(
          color: Colors.black12,
          height: 2,
        ),
      ],
    );
  }
}
