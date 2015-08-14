### =========================================================================
### getTranscriptSeqs methods 
### =========================================================================

setMethod("getTranscriptSeqs",  c("GRangesList", "ANY"),
    function(query, subject, ...)
    {
    .Deprecated("extractTransciptSeqs", old="getTranscriptSeqs")
    extractTranscriptSeqs(subject, query)
    }
)

setMethod("getTranscriptSeqs",  c("GRangesList", "FaFile"),
    function(query, subject, ...)
    {
    .Deprecated("extractTransciptSeqs", old="getTranscriptSeqs")
    extractTranscriptSeqs(subject, query)
    }
)
 
setMethod("getTranscriptSeqs",  c("GRanges", "FaFile"),
    function(query, subject, ...)
    {
    .Deprecated("extractTransciptSeqs", old="getTranscriptSeqs")
    extractTranscriptSeqs(subject, query)
    }
)

