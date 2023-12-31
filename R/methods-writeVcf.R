### =========================================================================
### writeVcf methods
### =========================================================================

.chunkIndex <- function(rows, nchunk, ...) 
{
    if (missing("nchunk")) {
        if (rows > 1e8) 
            n <- ceiling(rows / 3)
        else if (rows > 1e6) 
            n <- ceiling(rows / 2)
        else if (rows > 1e5) 
            n <- 1e5 
        else 
            return(NA_integer_)
    } else {
        if (is.na(nchunk))
            return(NA_integer_)
        else
            n <- nchunk
    }

    split(seq_len(rows), ceiling(seq_len(rows)/n))
}

.makeVcfMatrix <- function(filename, obj)
{
    ## empty
    if (length(rd <- rowRanges(obj)) == 0)
        return(character())

    CHROM <- as.vector(seqnames(rd))
    POS <- start(rd)
    if (is.null(ID <- names(rd)))
        ID <- "."
    REF <- as.character(ref(obj))
    if (is.null(ALT <- alt(obj)))
        ALT <- rep(".", length(REF))
    if (is(ALT, "XStringSetList")) {
        ALT <- as(ALT, "CharacterList")
    }
    ALT <- as.character(unstrsplit(ALT, ","))
    ALT[nchar(ALT) == 0L | is.na(ALT)] <- "."
    if (is.null(QUAL <- qual(obj)))
        QUAL <- "."
    else
        QUAL[is.na(QUAL)] <- "."
    if (is.null(FILTER <- filt(obj)))
        FILTER <- "."
    else
        FILTER[is.na(FILTER)] <- "."
    INFO <- .makeVcfInfo(info(obj), length(rd))
    FIXED <- paste(CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, sep="\t")
    .makeVcfGeno(filename, FIXED, geno(obj, withDimnames=FALSE), dim(obj))
}

.makeVcfGeno <- function(filename, fixed, geno, dvcf, ...)
{
    if ("GT" %in% names(geno)) {
        geno <- geno[c("GT", setdiff(names(geno), "GT"))]
    }
    .Call(.make_vcf_geno, filename, fixed, names(geno), 
        as.list(geno), c(":", ","), dvcf, 
        sapply(geno, function(x) dim(x)[3])) 
}

.makeVcfInfo <- function(info, nrecords, ...)
{
    if (ncol(info) == 0) {
      return(rep.int(".", nrecords))
    }

    ## Replace NA with '.' in columns with data.
    ## Columns with no data are set to NA.
    lists <- sapply(info, function(elt)
        is.list(elt) || is(elt, "List"))
    info[lists] <- lapply(info[lists], function(l) {
      charList <- as(l, "CharacterList")
      charList@unlistData[is.na(charList@unlistData)] <- "."
      collapsed <- unstrsplit(charList, ",")
      ifelse(sum(!is.na(l)) > 0L, collapsed, NA_character_)
    })

    ## Add names to non-NA data.
    infoMat <- matrix(".", nrow(info), ncol(info))
    logicals <- sapply(info, is.logical)
    infoMat[,logicals] <- unlist(Map(function(l, nm) {
      ifelse(l, nm, NA_character_)
    }, info[logicals], as(names(info)[logicals], "List")))

    infoMat[,!logicals] <- unlist(Map(function(i, nm) {
      ifelse(!is.na(i), paste0(nm, "=", i), NA_character_)
    }, info[!logicals], as(names(info)[!logicals], "List")))

    infoVector <- .pasteCollapseRows(infoMat, ";")
    infoVector[!nzchar(infoVector)] <- "."
    infoVector
}

.contigsFromSeqinfo <- function(si) 
{
    contig <- paste0("##contig=<ID=", seqnames(si))
    contig[!is.na(seqlengths(si))] <-
      paste0(contig, ",length=", seqlengths(si))[!is.na(seqlengths(si))]
    contig[!is.na(genome(si))] <-
      paste0(contig, ",assembly=\"", genome(si), "\"")[!is.na(genome(si))]
    paste0(contig, ">")
}

.pasteMultiFieldDF <- function(df, nms) {
    if (nrow(df) == 0L)
        return(character(0L))
    prs <- paste(rep(colnames(df), each=nrow(df)), "=",
                 unlist(lapply(df, as.character), use.names=FALSE),
                 sep="")
    lst <- split(prs, row(df))
    lns <- unstrsplit(lst, ",")
    paste("##", nms, "=<", lns, ">", sep="")
}

.makeVcfHeader <- function(obj, ...)
{
    hdr <- header(obj)
    ## If fileformat is >=v4.2 or does not exist --> set GENO 'AD' field
    ## to Number 'G'. The Number field indicates the number of values
    ## contained in the INFO field. 'G' is a special character and means
    ## the field has one value for each possible genotype. 
    fileformat <- "fileformat" %in% rownames(meta(hdr)$META)
    if (!fileformat)
        fileformat <- "fileformat" %in% names(meta(hdr))

    if (fileformat && grepl(fileformat, "v4.2", fixed=TRUE) || !fileformat) {
        if (any(idx <- rownames(geno(hdr)) == "AD"))
            geno(hdr)[idx,]$Number <- "G"
    }

    ## Format all header lines
    dflist <- header(hdr)
    header <- Map(.formatHeader, as.list(dflist), 
                  as.list(names(dflist)))

    ## If fileformat, fileDate or contig do not exist --> add them 
    fileDate <- any(grepl("fileDate", names(header), fixed=TRUE))
    if (!fileDate) {
        fileDate <- paste("##fileDate=", format(Sys.time(), "%Y%m%d"), sep="")
        header <- c(fileDate, header)
    }
    idx <- which(names(header) == "fileformat")
    if (length(idx) && idx != 1) {
        fileformat <- header[idx] 
        header[idx] <- NULL
        header <- c(fileformat, header) 
    }
    contig <- any(grepl("contig", names(header), fixed=TRUE))
    if (!contig)
        header <- c(header, .contigsFromSeqinfo(seqinfo(obj)))

    ## Last line before data
    colnms <- c("#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO")
    if (length(geno(obj, withDimnames=FALSE)) > 0L) {
        samples <- colnames(obj)
        colnms <- c(colnms, "FORMAT", samples[!is.null(samples)])
    }
    colnms <- paste(colnms, collapse="\t")
    unlist(c(header, colnms), use.names=FALSE)
}

.formatHeader <- function(df, nms)
{
    ## Support serialized VCF objects with old "META" DataFrame.
    if (nms == "META" && ncol(df) == 1L) {
        if (!"fileformat" %in% rownames(df))
            df <- rbind(DataFrame(Value="VCFv4.3", row.names="fileformat"), df)
        fd <- format(Sys.time(), "%Y%m%d")
        if ("fileDate" %in% rownames(df))
            df[rownames(df) == "fileDate", ] <- fd
        else
            df <- rbind(df, DataFrame(Value=fd, row.names="fileDate"))
        paste("##", rownames(df), "=", df[,1], sep="")
    ## Support VCF v4.2 and v4.3 PEDIGREE field
    } else if(nms == "PEDIGREE" || nms == "ALT") {
        if (!is.null(rownames(df)))
            df <- DataFrame(ID = rownames(df), df)
        if ("Description" %in% colnames(df)) {      # VJC respond LTLA 20 Nov 2021
            if (nrow(df) == 0L)
                return(character())
            df$Description <-
              ifelse(is.na(df$Description), "\".\"",
                           paste("\"", df$Description, "\"", sep=""))
        }                                           # end response
        .pasteMultiFieldDF(df, nms)
    ## 'simple' key-value pairs
    ## (Rsamtools reports unstructured headers as one column named "Value")
    } else if(ncol(df) == 1L && names(df)[1] == "Value" && nrow(df) == 1L) {
        if (nms == "fileDate") {
            fd <- format(Sys.time(), "%Y%m%d")
            paste("##fileDate=", fd, sep="")
        } else
            paste("##", nms, "=", df[,1], sep="")
    ## 'non-simple' key-value pairs
    } else {
        if ("Description" %in% colnames(df)) {
            if (nrow(df) == 0L)
                return(character())
            df$Description <-
              ifelse(is.na(df$Description), "\".\"",
                           paste("\"", df$Description, "\"", sep=""))
        }
        df <- DataFrame(ID = rownames(df), df)
        .pasteMultiFieldDF(df, nms)
    }
}

### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### VCF methods
###

setMethod(writeVcf, c("VCF", "character"),
    function(obj, filename, index = FALSE, ...)
{
    con <- file(filename, open="w")
    on.exit(close(con))

    writeVcf(obj, con, index=index, ...)
})

setMethod(writeVcf, c("VCF", "connection"),
    function(obj, filename, index = FALSE, ...)
{
    if (!isTRUEorFALSE(index))
        stop("'index' must be TRUE or FALSE")

    if (!isOpen(filename)) {
        open(filename)
        on.exit(close(filename))
    }

    scon <- summary(filename)
    headerNeeded <- !(file.exists(scon$description) &&
                      file.info(scon$description)$size !=0) 

    if (headerNeeded) {
        hdr <- .makeVcfHeader(obj)
        writeLines(hdr, filename)
    }

    if (index)
        obj <- sort(obj)

    if (all(is.na(idx <- .chunkIndex(dim(obj)[1L], ...))))
        .makeVcfMatrix(filename, obj)
    else
        for (i in idx)
            .makeVcfMatrix(filename, obj[i])
    flush(filename)

    if (index) {
        filenameGZ <- bgzip(scon$description, overwrite = TRUE)
        indexTabix(filenameGZ, format = "vcf")
        unlink(scon$description)
        invisible(filenameGZ)
    } else {
        invisible(scon$description)
    }
})

### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### VRanges methods
###

setMethod(writeVcf, "VRanges", function(obj, filename, ...)
{
    writeVcf(as(obj, "VCF"), filename, ...)
})
