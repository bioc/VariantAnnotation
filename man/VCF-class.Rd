\name{VCF-class}
\docType{class}

% Class
\alias{class:VCF}
\alias{VCF-class}
\alias{CollapsedVCF}
\alias{class:CollapsedVCF}
\alias{CollapsedVCF-class}
\alias{ExpandedVCF}
\alias{class:ExpandedVCF}
\alias{ExpandedVCF-class}

% Constructors:
\alias{VCF}

% Coercion methods:
\alias{SnpMatrixToVCF}

% Accessor methods:
\alias{updateObject,VCF-method}
\alias{fixed}
\alias{fixed,VCF-method}
\alias{fixed<-}
\alias{fixed<-,VCF,DataFrame-method}
\alias{ref}
\alias{ref,VCF-method}
\alias{ref<-}
\alias{ref<-,VCF,DNAStringSet-method}
\alias{alt}
\alias{alt,VCF-method}
\alias{alt<-}
\alias{alt<-,CollapsedVCF,CharacterList-method}
\alias{alt<-,ExpandedVCF,character-method}
\alias{alt<-,CollapsedVCF,DNAStringSetList-method}
\alias{alt<-,ExpandedVCF,DNAStringSet-method}
\alias{qual}
\alias{qual,VCF-method}
\alias{qual<-}
\alias{qual<-,VCF,numeric-method}
\alias{filt}
\alias{filt,VCF-method}
\alias{filt<-}
\alias{filt<-,VCF,character-method}
\alias{info}
\alias{info,VCF-method}
\alias{info<-}
\alias{info<-,VCF,DataFrame-method}
\alias{rowRanges,VCF-method}
\alias{rowRanges<-,VCF,GRanges-method}
\alias{mcols<-,VCF-method}
\alias{mcols<-,VCF,ANY-method}
\alias{dimnames<-,VCF,list-method}
\alias{geno}
\alias{geno,VCF-method}
\alias{geno,VCF,ANY-method}
\alias{geno,VCF,character-method}
\alias{geno,VCF,numeric-method}
\alias{geno,VCFHeader,ANY-method}
\alias{geno<-}
\alias{geno<-,VCF,character,matrix-method}
\alias{geno<-,VCF,numeric,matrix-method}
\alias{geno<-,VCF,missing,matrix-method}
\alias{geno<-,VCF,missing,SimpleList-method}
\alias{strand,VCF-method}
\alias{strand<-,VCF,ANY-method}
\alias{header,VCF-method}
\alias{header<-}
\alias{header<-,VCF,VCFHeader-method}
\alias{vcfFields,VCF-method}


% Subset methods
\alias{[,VCF-method}
\alias{[,VCF,ANY,ANY-method}
\alias{[,VCF,ANY,ANY,ANY-method}
\alias{subset,VCF-method}
\alias{[<-,VCF,ANY,ANY,VCF-method}

% Combine methods
\alias{cbind,VCF-method}
\alias{rbind,VCF-method}

% Other methods / functions
\alias{genome,VCF-method}
\alias{seqlevels,VCF-method}
\alias{expand,CollapsedVCF-method}
\alias{expand,ExpandedVCF-method}
\alias{genotypeCodesToNucleotides}

% show method:
\alias{show,VCF-method}
\alias{show,CollapsedVCF-method}
\alias{show,ExpandedVCF-method}

\title{VCF class objects}

\description{
  The VCF class is a virtual class extended from
  \code{RangedSummarizedExperiment}. The subclasses, \code{CompressedVCF}
  and \code{ExtendedVCF}, are containers for holding data from
  Variant Call Format files.
}

\section{Constructors}{
  \describe{
    \item{}{
      \code{readVcf(file, genome, param, ..., row.names=TRUE)}
    }
    \item{}{
      \code{VCF(rowRanges = GRanges(), colData = DataFrame(), 
                exptData = list(header = VCFHeader()), 
                fixed = DataFrame(), info = DataFrame(), 
                geno = SimpleList(), ..., collapsed=TRUE, 
                verbose = FALSE)}
      Creates CollapsedVCF when \code{collapsed = TRUE} and an
      ExpandedVCF when \code{collapsed = FALSE}.

      This is a low-level constructor used internally. Most instances
      of the \code{VCF} class are created with \code{readVCF}.
    }
  }
}

\section{Accessors}{
  In the following code snippets \code{x} is a CollapsedVCF or ExpandedVCF 
  object.
  \describe{
    \item{}{
      \code{rowRanges(x, ..., fixed = TRUE)}, \code{rowRanges(x) <- value}:
      Gets or sets the rowRanges. The CHROM, POS, ID, POS and REF fields are
      used to create a \code{GRanges} object. The start of the ranges are
      defined by POS and the width is equal to the width of the reference
      allele REF.  The IDs become the rownames. If they are missing (i.e.,
      \sQuote{.}) a string of CHROM:POS_REF/ALT is used instead.  The
      \code{genome} argument is stored in the seqinfo of the \code{GRanges} and
      can be accessed with \code{genome(<VCF>)}.
 
      When \code{fixed = TRUE}, REF, ALT, QUAL and FILTER metadata columns are 
      displayed as metadata columns. To modify the \code{fixed} fields, use
      the \code{fixed<-} setter. 

      One metadata column, \code{paramRangeID}, is included with the
      \code{rowRanges}. This ID is meaningful when multiple ranges are
      specified in the \code{ScanVcfParam} and distinguishes which records
      match each range.

      The metadata columns of a VCF object are accessed with the following:
      \itemize{
        \item{\code{ref(x)}, \code{ref(x) <- value}:
          Gets or sets the reference allele (REF). \code{value} must 
          be a \code{DNAStringSet}. 
        }
        \item{\code{alt(x)}, \code{alt(x) <- value}:
          Gets or sets the alternate allele data (ALT). When \code{x} is 
          a CollapsedVCF, \code{value} must be a \code{DNAStringSetList}
          or \code{CompressedCharacterList}. For ExpandedVCF, \code{value}
          must be a \code{DNAStringSet} or \code{character}.
        }
        \item{\code{qual(x)}, \code{qual(x) <- value}:
          Returns or sets the quality scores (QUAL). \code{value} must 
          be an \code{numeric(1L)}.
        }
        \item{\code{filt(x)}, \code{filt(x) <- value}:
          Returns or sets the filter data. \code{value} must 
          be a \code{character(1L)}. Names must be one of 'REF', 'ALT',
          'QUAL' or 'FILTER'.
        }
      }
    }
    \item{}{
      \code{mcols(x)}, \code{mcols(x) <- value}:
       These methods behave the same as \code{mcols(rowRanges(x))} and 
       \code{mcols(rowRanges(x)) <- value}. This method does not manage the
       fixed fields, 'REF', 'ALT', 'QUAL' or 'FILTER'. To modify those
       columns use \code{fixed<-}.
    }
    \item{}{
      \code{fixed(x)}, \code{fixed(x) <- value}:
       Gets or sets a DataFrame of REF, ALT, QUAL and FILTER only. 
       Note these fields are displayed as metadata columns with
       the rowRanges() data (set to fixed = FALSE to suppress).
    }
    \item{}{
      \code{info(x, ..., row.names = TRUE)}, \code{info(x) <- value}:
       Gets or sets a DataFrame of INFO variables. Row names are added
       if unique and \code{row.names=TRUE}.
    }
    \item{}{
      \code{geno(x, withDimnames=TRUE)}, \code{geno(x) <- value}:
       oets a SimpleList of genotype data.
       \code{value} is a SimpleList. To replace a single variable in
       the SimpleList use \code{geno(x)$variable <- value}; in this 
       case \code{value} must be a matrix or array. By default
       row names are returned; to override specify
       \code{geno(vcf, withDimnames=FALSE)}.
    }
    \item{}{
      \code{metadata(x)}:
       Gets a \code{list} of experiment-related data. By default this
       list includes the \sQuote{header} information from the VCF file. 
       See the use of \code{header()} for details in extracting
       header information. 
    }
    \item{}{
      \code{colData(x)}, \code{colData(x) <- value}:
      Gets or sets a \code{DataFrame} of sample-specific information. Each row 
      represents a sample in the VCF file. \code{value} must be a 
      \code{DataFrame} with rownames representing the samples in the VCF 
      file.
    }
    \item{}{
      \code{genome(x)}:
      Extract the \code{genome} information from the \code{GRanges} object
      returned by the \code{rowRanges} accessor.
    }
    \item{}{
      \code{seqlevels(x)}:
      Extract the \code{seqlevels} from the \code{GRanges} object
      returned by the \code{rowRanges} accessor.
    }
    \item{}{
      \code{strand(x)}:
      Extract the \code{strand} from the \code{GRanges} object
      returned by the \code{rowRanges} accessor.
    }
    \item{}{
      \code{header(x)}, \code{header(x)<- value}:
      Get or set the VCF header information. Replacement value
      must be a \code{VCFHeader} object. To modify individual elements 
      use \code{info<-}, \code{geno<-} or \code{meta<-} on a 
      \sQuote{VCFHeader} object. See ?\code{VCFHeader} man page for
      details.
       \itemize{
         \item{\code{info(header(x))}}
         \item{\code{geno(header(x))}}
         \item{\code{meta(header(x))}}
         \item{\code{samples(header(x))}}
      }
    }
    \item{}{\code{vcfFields(x)}
      Returns a \code{\link[IRanges]{CharacterList}} of all available VCF
      fields, with names of \code{fixed}, \code{info}, \code{geno} and
      \code{samples} indicating the four categories. Each element is a
      character() vector of available VCF field names within each category. 
    }
  }
}

\section{Subsetting and combining}{
  In the following code \code{x} is a VCF object, and \dots is a list
  of VCF objects.
  \describe{
    \item{}{
      \code{x[i, j]}, \code{x[i, j] <- value}: Gets or sets rows and columns.
      \code{i} and \code{j} can be integer or logical vectors. \code{value} is a
      replacement \code{VCF} object.
    }
    \item{}{
      \code{subset(x, subset, select, ...)}: Restricts \code{x} by
      evaluating the \code{subset} argument in the scope of
      \code{rowData(x)} and \code{info(x)}, and \code{select} in the
      context of \code{colData(x)}. The \code{subset} argument restricts
      by rows, while the \code{select} argument restricts by column. The
      \code{\dots} are passed to the underlying \code{subset()} calls.
    }
    \item{}{
      \code{cbind(...)}, \code{rbind(...)}: \code{cbind} combines objects with
      identical ranges (\code{rowRanges}) but different samples (columns in
      \code{assays}). The colnames in \code{colData} must match or an error is
      thrown. Columns with duplicate names in \code{fixed}, \code{info} and
      \code{mcols(rowRanges(VCF))} must contain the same data.

      \code{rbind} combines objects with different ranges (\code{rowRanges}) and
      the same subjects (columns in \code{assays}). Columns with duplicate names
      in \code{colData} must contain the same data.  The \sQuote{Samples}
      columns in \code{colData} (created by \code{readVcf}) are renamed with a
      numeric extension ordered as they were input to \code{rbind} e.g.,
      \dQuote{Samples.1, Samples.2, ...} etc. 

      \code{metadata} from all objects are combined into a
      \code{list} with no name checking.

    }
  }
}

\section{expand}{
  In the following code snippets \code{x} is a CollapsedVCF object.
  \describe{
    \item{}{
      \code{expand(x, ..., row.names = FALSE)}:
      Expand (unlist) the ALT column of a CollapsedVCF object to one row 
      per ALT value. Variables with Number='A' have one value per alternate
      allele and are expanded accordingly. The 'AD' genotype field 
      (and any variables with 'Number' set to 'R')
      is expanded into REF/ALT pairs. For all other fields, the rows
      are replicated to match the elementNROWS of ALT.

      The output is an ExpandedVCF with ALT as a \code{DNAStringSet} 
      or \code{character} (structural variants). By default rownames
      are NULL. When \code{row.names=TRUE} the expanded output has 
      duplicated rownames corresponding to the original \code{x}.
    }
  }
}

\section{genotypeCodesToNucleotides(vcf, ...)}{
  This function converts the `GT` genotype codes in a \code{VCF} object
  to nucleotides. See also ?\code{readGT} to read in only `GT` data as 
  codes or nucleotides.
}

\section{SnpMatrixToVCF(from, seqSource)}{
  This function converts the output from the \link[snpStats]{read.plink} 
  function to a \code{VCF} class. \code{from} must be a list of length 3
  with named elements "map", "fam" and "genotypes". \code{seqSource} can
  be a \code{\link[BSgenome]{BSgenome}} or an \link{FaFile}
  used for reference sequence extraction.
}

\section{Variant Type}{
  Functions to identify variant type include \link{isSNV}, 
  \link{isInsertion}, \link{isDeletion}, \link{isIndel}, 
  \link{isSubstitution} and \link{isTransition}. See the ?\code{isSNV} 
  man page for details.
}

\section{Arguments}{
  \describe{
    \item{geno}{A \code{list} or \code{SimpleList} of matrix elements,
      or a \code{matrix} containing the genotype information from a
      VCF file. If present, these data immediately follow the FORMAT
      field in the VCF. 

      Each element of the list must have the same dimensions, and dimension 
      names (if present) must be consistent across elements and with the row 
      names of \code{rowRanges}, \code{colData}. 
    }
    \item{info}{A \code{DataFrame} of data from the INFO field of a VCF file. 
      The number of rows must match that in the \code{rowRanges} object.
    }
    \item{fixed}{A \code{DataFrame} of REF, ALT, QUAL and FILTER 
      fields from a VCF file. The number of rows must match that
      of the \code{rowRanges} object.
    }
    \item{rowRanges}{A \code{GRanges} instance describing the ranges of
      interest. 
      Row names, if present, become the row names of the \code{VCF}. The length 
      of the \code{GRanges} must equal the number of rows of the matrices in 
      \code{geno}.
    }
    \item{colData}{A \code{DataFrame} describing the samples. Row names, if 
      present, become the column names of the \code{VCF}.
    }
    \item{metadata}{A \code{list} describing the header of the VCF file or 
      additional information for the overall experiment. 
    }
    \item{...}{For \code{cbind} and \code{rbind} a list of VCF objects.
      For all other methods \dots are additional arguments passed to methods. 
    }
    \item{collapsed}{A \code{logical(1)} indicating whether a 
      CollapsedVCF or ExpandedVCF should be created. The ALT in a
      CollapsedVCF is a \code{DNAStringSetList} while in a
      ExpandedVCF it is a \code{DNAStringSet}. 
    }
    \item{verbose}{A \code{logical(1)} indicating whether messages
      about data coercion during construction should be printed.
    }
  }
}

\details{
  The \code{VCF} class is a virtual class with two concrete subclasses,
  \code{CollapsedVCF} and \code{ExtendedVCF}. 

  Slots unique to \code{VCF} and subclasses,
  \itemize{
    \item \code{fixed}: A \link{DataFrame} containing the REF, ALT, QUAL 
      and FILTER fields from a VCF file.
    \item \code{info}: A \link{DataFrame} containing the INFO fields from 
      a VCF file.
  }

  Slots inherited from \code{RangedSummarizedExperiment},
  \itemize{
    \item \code{metadata}: A \code{list} containing the 
          file header or other information about the overall experiment.
    \item \code{rowRanges}: A \link{GRanges}-class instance defining the
           variant ranges and associated metadata columns of REF, ALT, QUAL 
           and FILTER. While the REF, ALT, QUAL and FILTER fields can
           be displayed as metadata columns they cannot be modified with
           \code{rowRanges<-}. To modify these fields use \code{fixed<-}. 
    \item \code{colData}: A \link{DataFrame}-class instance describing the 
          samples and associated metadata.
    \item \code{geno}: The \code{assays} slot from
          \code{RangedSummarizedExperiment} has been renamed as \code{geno}
          for the VCF class. This slot contains the genotype information
          immediately following the FORMAT field in a VCF file. Each element
          of the \code{list} or \code{SimpleList} is a matrix or array. 
  }

  It is expected that users will not create instances of the VCF class
  but instead one of the concrete subclasses, CollapsedVCF or ExpandVCF.
  CollapsedVCF contains the ALT data as a \code{DNAStringSetList} allowing 
  for multiple alleles per variant. The ExpandedVCF ALT data is a 
  \code{DNAStringSet} where the ALT column has been expanded to create a 
  flat form of the data with one row per variant-allele combination. In 
  the case of strucutral variants, ALT will be a \code{CompressedCharacterList}
  or \code{character} in the collapsed or expanded forms.
}

\author{Valerie Obenchain}

\seealso{
  \link{GRanges},
  \link[S4Vectors]{DataFrame},
  \link[S4Vectors]{SimpleList},
  \link[SummarizedExperiment]{RangedSummarizedExperiment},
  \code{\link{readVcf}},
  \code{\link{writeVcf}}
  \code{\link{isSNV}}
}

\examples{

## readVcf() parses data into a VCF object: 

fl <- system.file("extdata", "structural.vcf", package="VariantAnnotation")
vcf <- readVcf(fl, genome="hg19")

## ----------------------------------------------------------------
## Accessors 
## ----------------------------------------------------------------
## Variant locations are stored in the GRanges object returned by
## the rowRanges() accessor.
rowRanges(vcf)

## Suppress fixed fields:
rowRanges(vcf, fixed=FALSE)

## Individual fields can be extracted with ref(), alt(), qual(), filt() etc.
qual(vcf)
ref(vcf)
head(info(vcf))

## All available VCF field names can be contracted with vcfFields(). 
vcfFields(vcf)

## Extract genotype fields with geno(). Access specific fields with 
## '$' or '[['.
geno(vcf)
identical(geno(vcf)$GQ, geno(vcf)[[2]])

## ----------------------------------------------------------------
## Renaming seqlevels and subsetting 
## ----------------------------------------------------------------
## Overlap and matching operations require that the objects
## being compared have the same seqlevels (chromosome names).
## It is often the case that the seqlevesls in on of the objects
## needs to be modified to match the other. In this VCF, the 
## seqlevels are numbers instead of preceded by "chr" or "ch". 

seqlevels(vcf)

## Rename the seqlevels to start with 'chr'.
vcf2 <- renameSeqlevels(vcf, paste0("chr", seqlevels(vcf))) 
seqlevels(vcf2)

## The VCF can also be subset by seqlevel using 'keepSeqlevels'
## or 'dropSeqlevels'. See ?keepSeqlevels for details. 
vcf3 <- keepSeqlevels(vcf2, "chr2", pruning.mode="coarse")
seqlevels(vcf3)

## ----------------------------------------------------------------
## Header information 
## ----------------------------------------------------------------

## Header data can be modified in the 'meta', 'info' and 'geno'
## slots of the VCFHeader object. See ?VCFHeader for details.

## Current 'info' fields.
rownames(info(header(vcf)))

## Add a new field to the header.
newInfo <- DataFrame(Number=1, Type="Integer",
                     Description="Number of Samples With Data",
                     row.names="NS")
info(header(vcf)) <- rbind(info(header(vcf)), newInfo)
rownames(info(header(vcf)))

## ----------------------------------------------------------------
## Collapsed and Expanded VCF 
## ----------------------------------------------------------------
## readVCF() produces a CollapsedVCF object.
fl <- system.file("extdata", "ex2.vcf", 
                  package="VariantAnnotation")
vcf <- readVcf(fl, genome="hg19")
vcf

## The ALT column is a DNAStringSetList to allow for more
## than one alternate allele per variant.
alt(vcf)

## For structural variants ALT is a CharacterList.
fl <- system.file("extdata", "structural.vcf", 
                  package="VariantAnnotation")
vcf <- readVcf(fl, genome="hg19")
alt(vcf)

## ExpandedVCF is the 'flattened' counterpart of CollapsedVCF.
## The ALT and all variables with Number='A' in the header are
## expanded to one row per alternate allele.
vcfLong <- expand(vcf)
alt(vcfLong)

## Also see the ?VRanges class for an alternative form of
## 'flattened' VCF data.

## ----------------------------------------------------------------
## isSNV()
## ----------------------------------------------------------------
## isSNV() returns a subset VCF containing SNVs only.

vcf <- VCF(rowRanges = GRanges("chr1", IRanges(1:4*3, width=c(1, 2, 1, 1))))
alt(vcf) <- DNAStringSetList("A", c("TT"), c("G", "A"), c("TT", "C"))
ref(vcf) <- DNAStringSet(c("G", c("AA"), "T", "G"))
fixed(vcf)[c("REF", "ALT")]

## SNVs are present in rows 1 (single ALT value), 3 (both ALT values) 
## and 4 (1 of the 2 ALT values).
vcf[isSNV(vcf, singleAltOnly=TRUE)] 
vcf[isSNV(vcf, singleAltOnly=FALSE)] ## all 3 SNVs
}
