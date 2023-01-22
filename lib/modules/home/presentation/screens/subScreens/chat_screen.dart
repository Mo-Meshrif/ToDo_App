import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/helper/helper_functions.dart';
import '../../../../../app/utils/assets_manager.dart';
import '../../../../../app/utils/color_manager.dart';
import '../../../../../app/utils/constants_manager.dart';
import '../../../../../app/utils/values_manager.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../domain/entities/chat_message.dart';
import '../../controller/home_bloc.dart';
import '../../widgets/customMessage/custom_message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  String uid = HelperFunctions.getSavedUser().id;

  @override
  Widget build(BuildContext context) {
    var homeBloc = BlocProvider.of<HomeBloc>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: AppSize.s2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
            child: SvgPicture.asset(
              IconAssets.appTitle,
              color: ColorManager.kWhite,
              width: AppSize.s120,
            ),
          )
        ],
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: homeBloc.getChatList(),
        builder: (context, snapshot) {
          List<ChatMessage> data = snapshot.hasData ? snapshot.data! : [];
          return StatefulBuilder(
            builder: (context, innerState) {
              if (snapshot.connectionState == ConnectionState.active) {
                messages = HelperFunctions.refactorChatList(
                  messages,
                  data,
                  uid,
                );
              }
              return MessageWidget(
                uid: uid,
                messages: messages,
                loading: messages.isEmpty &&
                    snapshot.connectionState == ConnectionState.waiting,
                sendMessage: (message, type) async {
                  if (message != null) {
                    var chatMessage = ChatMessageModel(
                      uid: uid,
                      idFrom: uid,
                      idTo: AppConstants.toAdmin,
                      timestamp: Timestamp.now().toString(),
                      content: message,
                      type: type,
                      isMark: true,
                      isLoading: true,
                      isLocal: true,
                    );
                    innerState(() => messages.insert(0, chatMessage));
                    homeBloc.add(
                      SendMessageEvent(
                        chatMessage,
                      ),
                    );
                  }
                },
                updateMessage: (message) => homeBloc.add(
                  UpdateMessageEvent(message),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
