\name{summarizeVariants}

\alias{summarizeVariants}
\alias{summarizeVariants,TxDb,VCF,CodingVariants-method}
\alias{summarizeVariants,TxDb,VCF,FiveUTRVariants-method}
\alias{summarizeVariants,TxDb,VCF,ThreeUTRVariants-method}
\alias{summarizeVariants,TxDb,VCF,SpliceSiteVariants-method}
\alias{summarizeVariants,TxDb,VCF,IntronVariants-method}
\alias{summarizeVariants,TxDb,VCF,PromoterVariants-method}
\alias{summarizeVariants,GRangesList,VCF,VariantType-method}
\alias{summarizeVariants,GRangesList,VCF,function-method}

\title{Summarize variants by sample}

\description{
  Variants in a VCF file are overlapped with an annotation 
  region and summarized by sample. Genotype information in
  the VCF is used to determine which samples express 
  each variant.
}

\usage{
\S4method{summarizeVariants}{TxDb,VCF,CodingVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{TxDb,VCF,FiveUTRVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{TxDb,VCF,ThreeUTRVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{TxDb,VCF,SpliceSiteVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{TxDb,VCF,IntronVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{TxDb,VCF,PromoterVariants}(query, subject, mode, ...)
\S4method{summarizeVariants}{GRangesList,VCF,VariantType}(query, subject, mode, ...)
\S4method{summarizeVariants}{GRangesList,VCF,function}(query, subject, mode, ...)
}

\arguments{
  \item{query}{A \link[GenomicFeatures]{TxDb} or \code{GRangesList}
    object that serves as the annotation. GFF files can be converted to
    \link[GenomicFeatures]{TxDb} objects with 
    \code{makeTxDbFromGFF()} in the \code{txdbmaker} package.
  }
  \item{subject}{A \linkS4class{VCF} object containing the variants.
  }
  \item{mode}{\code{mode} can be a \code{VariantType} class or the
    name of a function. 

    When \code{mode} is a \code{VariantType} class, counting is done with
    \code{locateVariants} and counts are summarized transcript-by-sample. 
    Supported \code{VariantType} classes include 
    \code{CodingVariants}, \code{IntronVariants}, \code{FiveUTRVariants}, 
    \code{ThreeUTRVariants}, \code{SpliceSiteVariants} or \code{PromoterVariants}. 
    \code{AllVariants()} and \code{IntergenicVariants} are not supported. See 
    ?\code{locateVariants} for more detail on the variant classes.

    \code{mode} can also be the name of any counting function that outputs
    a \code{Hits} object. Variants will be summarized by the length of the
    \code{GRangesList} annotation (i.e., 'length-of-GRangesList'-by-sample).
  }
  \item{\dots}{Additional arguments passed to methods such as
    \describe{
      \item{ignore.strand}{A \code{logical} indicating if strand should be
        igored when performing overlaps.
      }
    }
  }
}

\details{
  \code{summarizeVariants} uses the genotype information in a VCF
  file to determine which samples are positive for each variant.
  Variants are overlapped with the annotation and the counts
  are summarized annotation-by-sample. If the annotation is a 
  \code{GRangesList} of transcripts, the count matrix will 
  be transcripts-by-sample. If the \code{GRangesList} is genes,
  the count matrix will be gene-by-sample.

  \itemize{
    \item{Counting with locateVariants() :}{

      Variant counts are always summarized transcript-by-sample.
      When \code{query} is a \code{GRangesList}, it must be compatible 
      with the \code{VariantType}-class given as the \code{mode} argument. 
      The list below specifies the appropriate \code{GRangesList} for each
      \code{mode}.
      \describe{
        \item{CodingVariants :}{coding (CDS) by transcript}
        \item{IntronVariants :}{introns by transcript}
        \item{FiveUTRVariants :}{five prime UTR by transcript}
        \item{ThreeUTRVariants :}{three prime UTR by transcript}
        \item{SpliceSiteVariants :}{introns by transcript}
        \item{PromoterVariants :}{list of transcripts}
      }

      When \code{query} is a \code{TxDb}, the appropriate 
      region-by-transcript \code{GRangesList} listed above is extracted 
      internally and used as the annotation. 

    }
 
    \item{Counting with a user-supplied function :}{

      \code{subject} must be a \code{GRangesList} and \code{mode} must
      be the name of a function. The count function must take 'query'
      and 'subject' arguments and return a \code{Hits} object. Counts are 
      summarized by the outer list elements of the \code{GRangesList}.
    }
  }
}

\value{
  A \code{RangedSummarizedExperiment} object with count summaries in the 
  \code{assays} slot. The \code{rowRanges} contains the annotation
  used for counting. Information in \code{colData} and \code{metadata} 
  are taken from the VCF file.
}

\author{Valerie Obenchain}

\seealso{
  \code{\link{readVcf}},
  \code{\link{predictCoding}},
  \code{\link{locateVariants}}
}

\examples{
  library(TxDb.Hsapiens.UCSC.hg19.knownGene)
  txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene 

  ## Read variants from VCF.
  fl <- system.file("extdata", "chr22.vcf.gz", package="VariantAnnotation")
  vcf <- readVcf(fl, "hg19")
  ## Rename seqlevels to match TxDb; confirm the match.
  seqlevels(vcf) <- paste0("chr", seqlevels(vcf)) 
  intersect(seqlevels(vcf), seqlevels(txdb))

  ## ----------------------------------------
  ## Counting with locateVariants()
  ## ----------------------------------------
  ## TxDb as the 'query'
  coding1 <- summarizeVariants(txdb, vcf, CodingVariants())
  colSums(assays(coding1)$counts)

  ## GRangesList as the 'query'
  cdsbytx <- cdsBy(txdb, "tx")
  coding2 <- summarizeVariants(cdsbytx, vcf, CodingVariants()) 

  stopifnot(identical(assays(coding1)$counts, assays(coding2)$counts))

  ## Promoter region variants summarized by transcript
  tx <- transcripts(txdb)
  txlst <- splitAsList(tx, seq_len(length(tx)))
  promoter <- summarizeVariants(txlst, vcf, 
                                PromoterVariants(upstream=100, downstream=10))
  colSums(assays(promoter)$counts)

  ## ----------------------------------------
  ## Counting with findOverlaps() 
  ## ----------------------------------------

  ## Summarize all variants by transcript
  allvariants <- summarizeVariants(txlst, vcf, findOverlaps)
  colSums(assays(allvariants)$counts)
}

\keyword{methods}
