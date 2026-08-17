import AppKit
import Carbon

private struct Suggestion {
    let title: String
    let kind: String
    let value: String
}

private final class PalettePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

private final class CompletionEngine {
    private let fm = FileManager.default
    private(set) var commands: [String] = []

    init() {
        loadCommands()
    }

    func matches(_ query: String) -> [Suggestion] {
        guard !query.isEmpty else { return [] }

        let token = currentToken(query)
        var result: [Suggestion] = []

        if token.text.contains("/") || token.start > query.startIndex {
            result += paths(query, token: token)
        } else {
            let needle = token.text.lowercased()
            result += commands
                .filter { $0.lowercased().hasPrefix(needle) }
                .prefix(8)
                .map { Suggestion(title: $0, kind: "command", value: replace(query, token, with: $0)) }
        }

        var seen = Set<String>()
        return Array(result.filter { seen.insert($0.value).inserted }.prefix(8))
    }

    private func loadCommands() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = [
                "-ic",
                "print -rl -- ${(k)commands} ${(k)aliases} ${(k)builtins} ${(k)functions} ${(k)reswords}",
            ]
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            guard (try? process.run()) != nil else { return }
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let values = String(decoding: data, as: UTF8.self)
                .split(separator: "\n").map(String.init).sorted()
            DispatchQueue.main.async { self?.commands = values }
        }
    }

    private func currentToken(_ query: String) -> (start: String.Index, text: String) {
        var start = query.startIndex
        var quote: Character?
        var escaped = false
        for i in query.indices {
            let c = query[i]
            if escaped { escaped = false }
            else if c == "\\" { escaped = true }
            else if c == "\"" || c == "'" { quote = quote == c ? nil : (quote == nil ? c : quote) }
            else if c.isWhitespace && quote == nil { start = query.index(after: i) }
        }
        return (start, String(query[start...]))
    }

    private func paths(
        _ query: String,
        token: (start: String.Index, text: String)
    ) -> [Suggestion] {
        let raw = token.text.replacingOccurrences(of: "\\ ", with: " ")
        let homeURL = fm.homeDirectoryForCurrentUser
        let expanded = NSString(string: raw).expandingTildeInPath
        let url = expanded.hasPrefix("/")
            ? URL(fileURLWithPath: expanded)
            : homeURL.appendingPathComponent(expanded)
        let directory = raw.isEmpty
            ? homeURL
            : (raw.hasSuffix("/") ? url : url.deletingLastPathComponent())
        let prefix = raw.hasSuffix("/") ? "" : url.lastPathComponent
        guard let children = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return children
            .filter { prefix.isEmpty || $0.lastPathComponent.hasPrefix(prefix) }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .prefix(8)
            .map { child in
                let isDirectory = (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let suffix = isDirectory ? "/" : ""
                var path: String
                if raw.hasPrefix("/") {
                    path = child.path
                } else if raw.hasPrefix("~") {
                    let home = fm.homeDirectoryForCurrentUser.path
                    path = child.path.hasPrefix(home)
                        ? "~" + child.path.dropFirst(home.count)
                        : child.path
                } else {
                    let parent = raw.hasSuffix("/")
                        ? String(raw.dropLast())
                        : NSString(string: raw).deletingLastPathComponent
                    path = parent.isEmpty || parent == "."
                        ? child.lastPathComponent
                        : parent + "/" + child.lastPathComponent
                }
                path = path.replacingOccurrences(of: " ", with: "\\ ") + suffix
                return Suggestion(
                    title: child.lastPathComponent + suffix,
                    kind: isDirectory ? "directory" : "file",
                    value: replace(query, token, with: path)
                )
            }
    }

    private func replace(
        _ query: String,
        _ token: (start: String.Index, text: String),
        with value: String
    ) -> String {
        String(query[..<token.start]) + value
    }
}

private final class PaletteController: NSObject,
    NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate {
    private let engine = CompletionEngine()
    private let panel = PalettePanel(
        contentRect: NSRect(x: 0, y: 0, width: 680, height: 58),
        styleMask: [.borderless, .nonactivatingPanel],
        backing: .buffered,
        defer: false
    )
    private let input = NSTextField()
    private let table = NSTableView()
    private let scroll = NSScrollView()
    private var suggestions: [Suggestion] = []
    private var completionVisible = false
    private var previousApplication: NSRunningApplication?

    override init() {
        super.init()
        configurePanel()
        configureInput()
        configureTable()
        layout()
    }

    func toggle() { panel.isVisible ? hide() : show() }

    private func show() {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            previousApplication = frontmost
        }
        completionVisible = false
        suggestions = []
        table.reloadData()
        resize()
        let frame = screen.visibleFrame
        panel.setFrameOrigin(NSPoint(
            x: frame.midX - panel.frame.width / 2,
            y: frame.minY + frame.height * 0.10
        ))
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(input)
    }

    private func hide(restoreFocus: Bool = true) {
        panel.orderOut(nil)
        if restoreFocus {
            previousApplication?.activate(options: [])
        }
        previousApplication = nil
    }

    private func configurePanel() {
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = true
        let effect = NSVisualEffectView(frame: panel.contentView!.bounds)
        effect.autoresizingMask = [.width, .height]
        effect.material = .hudWindow
        effect.blendingMode = .behindWindow
        effect.state = .active
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 12
        effect.layer?.masksToBounds = true
        effect.layer?.borderWidth = 1
        effect.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        panel.contentView = effect
    }

    private func configureInput() {
        input.delegate = self
        input.isBordered = false
        input.drawsBackground = false
        input.focusRingType = .none
        input.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        input.textColor = .labelColor
        input.placeholderString = "❯  Run a command…"
        input.cell?.usesSingleLineMode = true
        panel.contentView?.addSubview(input)
    }

    private func configureTable() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("item"))
        column.resizingMask = .autoresizingMask
        table.addTableColumn(column)
        table.headerView = nil
        table.rowHeight = 31
        table.intercellSpacing = NSSize(width: 0, height: 1)
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.doubleAction = #selector(acceptSuggestion)
        scroll.documentView = table
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        panel.contentView?.addSubview(scroll)
    }

    private func layout() {
        input.frame = NSRect(x: 20, y: panel.frame.height - 49, width: 640, height: 36)
        scroll.frame = NSRect(x: 12, y: 10, width: 656, height: panel.frame.height - 68)
    }

    private func resize() {
        let tableHeight = CGFloat(suggestions.count) * 32
        let visibleHeight = CGFloat(min(suggestions.count, 6)) * 32
        panel.setContentSize(NSSize(width: 680, height: 58 + visibleHeight))
        layout()
        table.frame = NSRect(x: 0, y: 0, width: scroll.frame.width, height: tableHeight)
        if panel.isVisible, let screen = panel.screen ?? NSScreen.main {
            let frame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(
                x: frame.midX - panel.frame.width / 2,
                y: frame.minY + frame.height * 0.10
            ))
        }
    }

    func controlTextDidChange(_ notification: Notification) {
        completionVisible = false
        suggestions = []
        table.reloadData()
        resize()
    }

    func control(
        _ control: NSControl,
        textView: NSTextView,
        doCommandBy selector: Selector
    ) -> Bool {
        switch selector {
        case #selector(NSResponder.insertNewline(_:)):
            execute()
        case #selector(NSResponder.insertTab(_:)):
            if !completionVisible {
                showCompletions()
            } else {
                cycleSuggestion()
            }
        case #selector(NSResponder.moveDown(_:)):
            moveSelection(1)
        case #selector(NSResponder.moveUp(_:)):
            moveSelection(-1)
        case #selector(NSResponder.cancelOperation(_:)):
            hide()
        default:
            return false
        }
        return true
    }

    func numberOfRows(in tableView: NSTableView) -> Int { suggestions.count }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("cell")
        let cell = tableView.makeView(withIdentifier: id, owner: self) as? NSTableCellView
            ?? NSTableCellView()
        cell.identifier = id
        let label: NSTextField
        if let existing = cell.textField { label = existing }
        else {
            label = NSTextField(labelWithString: "")
            label.frame = NSRect(x: 8, y: 5, width: 620, height: 21)
            label.autoresizingMask = [.width]
            label.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            label.lineBreakMode = .byTruncatingMiddle
            cell.addSubview(label)
            cell.textField = label
        }
        let item = suggestions[row]
        let text = NSMutableAttributedString(string: item.title, attributes: [
            .foregroundColor: NSColor.labelColor,
        ])
        text.append(NSAttributedString(string: "   " + item.kind, attributes: [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: NSFont.systemFont(ofSize: 12),
        ]))
        label.attributedStringValue = text
        return cell
    }

    private func updateSuggestions() {
        suggestions = engine.matches(input.stringValue)
        table.reloadData()
        table.deselectAll(nil)
    }

    private func showCompletions() {
        completionVisible = true
        updateSuggestions()
        resize()
        if suggestions.count == 1 {
            table.selectRowIndexes([0], byExtendingSelection: false)
            acceptSuggestion()
        }
    }

    private func cycleSuggestion() {
        guard !suggestions.isEmpty else { return }
        let next = (table.selectedRow + 1) % suggestions.count
        table.selectRowIndexes([next], byExtendingSelection: false)
        table.scrollRowToVisible(next)
        setInput(suggestions[next].value)
    }

    private func moveSelection(_ offset: Int) {
        guard !suggestions.isEmpty else { return }
        let current = table.selectedRow
        let next = current < 0
            ? (offset > 0 ? 0 : suggestions.count - 1)
            : min(max(current + offset, 0), suggestions.count - 1)
        table.selectRowIndexes([next], byExtendingSelection: false)
        table.scrollRowToVisible(next)
    }

    @objc private func acceptSuggestion() {
        guard table.selectedRow >= 0 && table.selectedRow < suggestions.count else { return }
        setInput(suggestions[table.selectedRow].value)
        completionVisible = false
        updateSuggestions()
        suggestions = []
        table.reloadData()
        resize()
    }

    private func setInput(_ value: String) {
        input.stringValue = value
        panel.makeFirstResponder(input)
        if let editor = input.currentEditor() {
            editor.selectedRange = NSRange(location: input.stringValue.utf16.count, length: 0)
        }
    }

    private func execute() {
        let command = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        input.stringValue = ""
        hide(restoreFocus: false)

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", command]
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            DispatchQueue.global(qos: .utility).async {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                let status = process.terminationStatus
                let output = String(decoding: data, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard status != 0 || !output.isEmpty else { return }
                DispatchQueue.main.async {
                    NSApp.activate(ignoringOtherApps: true)
                    let alert = NSAlert()
                    alert.alertStyle = status == 0 ? .informational : .warning
                    alert.messageText = status == 0
                        ? "Command finished" : "Command failed (\(status))"
                    alert.informativeText = output.isEmpty ? command : String(output.prefix(4000))
                    alert.runModal()
                }
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var palette: PaletteController?
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        palette = PaletteController()
        var event = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, context in
                guard let context else { return noErr }
                Unmanaged<AppDelegate>.fromOpaque(context)
                    .takeUnretainedValue().palette?.toggle()
                return noErr
            },
            1,
            &event,
            Unmanaged.passUnretained(self).toOpaque(),
            &handler
        )
        let id = EventHotKeyID(signature: OSType(0x4350_4C54), id: 1)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_E), UInt32(cmdKey), id,
            GetApplicationEventTarget(), 0, &hotKey
        )
    }
}

let application = NSApplication.shared
private let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
