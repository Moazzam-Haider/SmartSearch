// Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _messages.length,
//                 itemBuilder: (context, index) {
//                   final message = _messages[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (message.containsKey('user'))
//                               Text(
//                                 message['user'],
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             if (message.containsKey('filePath') &&
//                                 message['fileType'] == 'document')
//                               Text(
//                                 'Document: ${message['filePath']}',
//                                 style: const TextStyle(color: Colors.blue),
//                               ),
//                             if (message.containsKey('filePath') &&
//                                 message['fileType'] == 'image')
//                               Image.file(
//                                 File(message['filePath']),
//                                 height: 200,
//                                 width: 200,
//                                 fit: BoxFit.cover,
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : const SizedBox.shrink(),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.attach_file),
//                     onPressed: _showAttachmentOptions,
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message',
//                       ),
//                       onSubmitted: (value) => sendMessage(),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),