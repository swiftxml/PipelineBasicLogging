import Testing
import Pipeline
import PipelineBasicLogging

@Suite struct PipelineBasicLoggingTests {
    
    @Test func test1() async throws {
        
        let collectingLogger = CollectingLogger<ExecutionLogEntry,InfoType>()
        
        let printer = LogEntryPrinter()
        
        let logger = MultiLogger(collectingLogger, printer)
        
        let eventProcessor = EventProcessorForLogger(
            withMetaDataInfo: "Test",
            logger: logger,
            severityTracker: ConcurrentSeverityTracker(),
            excutionInfoFormat: ExecutionInfoFormat(
                withTime: false,
                addMetaDataInfo: true,
                addIndentation: true,
                addType: true,
                addExecutionPath: true,
                addStructuralID: false
            )
        )
        
        let execution = Execution(executionEventProcessor: eventProcessor)
        
        @Step
        func step1(during execution: Execution) {
            step2(during: execution)
        }
        
        @Step
        func step2(during execution: Execution) {
            execution.log(Message(id: "where am I", type: .info, fact: [.en: "I am in step 2"]))
        }
        
        step1(during: execution)
        
        try execution.closeEventProcessing()
        
        #expect(collectingLogger.getMessages().map{ $0.description }.joined(separator: "\n") == """
            Test: {progress} beginning step step1(during:)@PipelineBasicLoggingTests
            Test:     {progress} beginning step step2(during:)@PipelineBasicLoggingTests [@@ step step1(during:)@PipelineBasicLoggingTests -> ]
            Test:         {info} [where am I]: I am in step 2 [@@ step step1(during:)@PipelineBasicLoggingTests -> step step2(during:)@PipelineBasicLoggingTests]
            Test:     {progress} ending step step2(during:)@PipelineBasicLoggingTests [@@ step step1(during:)@PipelineBasicLoggingTests -> ]
            Test: {progress} ending step step1(during:)@PipelineBasicLoggingTests
            """)
        
    }
    
}

