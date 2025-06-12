import SwiftUI

// MARK: - Model（增加 timestamp）
struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let avatarColor: Color
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSentByMe: Bool
    let timestamp: Date    // 新增：消息时间
}

// MARK: - Contact List（保持不变）
struct ContactListView: View {
    private let contacts = [
        Contact(name: "🇫🇷 김지우", avatarColor: .orange),
        Contact(name: "🇮🇳 박규태", avatarColor: Color(red: 0.75, green: 0.75, blue: 0.9)),
        Contact(name: "🇨🇦 이은혜", avatarColor: .blue)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.yellow.ignoresSafeArea()
                VStack(spacing: 16) {
                    ForEach(contacts) { contact in
                        NavigationLink(destination: ChatView(contact: contact)) {
                            HStack {
                                Circle()
                                    .fill(contact.avatarColor)
                                    .frame(width: 40, height: 40)
                                Text(contact.name)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Chat Screen（全面升级）
struct ChatView: View {
    let contact: Contact
    @State private var messages: [Message] = [
        //Message(text: "안녕! 잘 지내?", isSentByMe: false, timestamp: Date())
    ]
    @State private var draft = ""
    
    // 时间格式化器
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    var body: some View {
        ZStack {
            // 1) 背景白色铺满
            Color.white
                .ignoresSafeArea()
            
            // 2) 太阳图标：右上角
            Image(systemName: "sun.max.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.yellow)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                //.offset(y: +50)
            
            // 3) 月亮图标：左下角
            Image(systemName: "moon.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.gray)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(y: -50)
            
            VStack(spacing: 0) {
                // 上部导航栏自动成蓝底白字由 .toolbarBackground 实现
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            VStack(alignment: msg.isSentByMe ? .trailing : .leading, spacing: 4) {
                                // 时间戳
                                Text(timeFormatter.string(from: msg.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                
                                
                                // 气泡
                                HStack {
                                    if msg.isSentByMe { Spacer() }
                                    Text(msg.text)
                                        .padding(12)
                                        .background(
                                            msg.isSentByMe
                                            ? Color.blue.opacity(0.3)      // 我方：浅蓝
                                            : Color.gray.opacity(0.3)      // 对方：原灰
                                        )
                                        .foregroundColor(msg.isSentByMe ? .black : .black)
                                        .cornerRadius(16)
                                    if !msg.isSentByMe { Spacer() }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
                
              
                
                // 底部输入栏
                HStack(spacing: 8) {
                    TextField("Type here", text: $draft)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .submitLabel(.send)            // 让键盘回车变“发送”
                        .onSubmit {
                            sendMessage(draft)
                        }
                    Button {
                        sendMessage(draft)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .rotationEffect(.degrees(45))
                            .font(.title2)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))  // 外部浅灰
            }
            .navigationTitle(contact.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.blue, for: .navigationBar)   // 导航栏蓝底
            .toolbarColorScheme(.dark, for: .navigationBar)       // 导航栏白字
        }
    }
    
    /// 发送并固定自动回复
    private func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let now = Date()
        // 我方消息
        messages.append(Message(text: text, isSentByMe: true, timestamp: now))
        draft = ""
        // 延迟自动回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.append(
                Message(
                    text: "재미있어! 과제다하고 연락할게!",
                    isSentByMe: false,
                    timestamp: Date()
                )
            )
        }
    }
}
