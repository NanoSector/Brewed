//
//  LogView.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import SwiftUI

struct LogView: View {
    @ObservedObject var watcher: LogWatcher

    @State var scrollToBottom = true

    var body: some View {
        VStack {
            Toggle("Watch file changes", isOn: $scrollToBottom).padding(.top)
            Text("Last updated \(watcher.lastChanged.format(date: .short, time: .medium))").font(.subheadline)

            ScrollView {
                ScrollViewReader { scrollView in
                    ForEach(watcher.contentsPerLine, id: \.self) { line in
                        Text(line)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(line.logColor()?.opacity(0.25))
                            .contextMenu {
                                Button(action: {
                                    NSPasteboard.general.declareTypes([.string], owner: nil)
                                    NSPasteboard.general.setString(line, forType: .string)
                                }) {
                                    Text("Copy")
                                }
                            }
                    }
                    .onAppear {
                        scroll(view: scrollView)
                    }
                    .onChange(of: watcher.contentsPerLine.count) { _ in
                        scroll(view: scrollView)
                    }
                }
            }
        }
    }

    func scroll(view: ScrollViewProxy) {
        if scrollToBottom, watcher.contentsPerLine.count > 0 {
            view.scrollTo(watcher.contentsPerLine[watcher.contentsPerLine.count - 1])
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(watcher: LogWatcher())
    }
}
