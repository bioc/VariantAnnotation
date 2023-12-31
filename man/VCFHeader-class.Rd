\name{VCFHeader-class}
\docType{class}

% Class
\alias{VCFHeader-class}

% Constructor-like function:
\alias{VCFHeader}

% Accessor methods:
\alias{reference}
\alias{reference,VCFHeader-method}
\alias{samples}
\alias{samples,VCFHeader-method}
\alias{header}
\alias{header,VCFHeader-method}

\alias{contig}
\alias{contig,VCFHeader-method}
\alias{meta}
\alias{meta,VCFHeader-method}
\alias{meta<-}
\alias{meta<-,VCFHeader,DataFrame-method}
\alias{meta<-,VCFHeader,DataFrameList-method}
\alias{fixed,VCFHeader-method}
\alias{fixed<-,VCFHeader,DataFrameList-method}
\alias{info,VCFHeader-method}
\alias{info<-,VCFHeader,DataFrame-method}
\alias{geno,VCFHeader-method}
\alias{geno<-,VCFHeader,missing,DataFrame-method}
\alias{seqinfo,VCFHeader-method}
\alias{vcfFields}
\alias{vcfFields,VCFHeader-method}

% show method:
\alias{show,VCFHeader-method}

\title{VCFHeader instances}

\description{
  The \code{VCFHeader} class holds Variant Call Format (VCF) file 
  header information and is produced from a call to \code{scanVcfHeader}.
}

\section{Constructor}{
  \describe{
    \item{}{
      \code{VCFHeader(reference = character(), samples = character(), 
                      header = DataFrameList(), ...)
      }
    }
  }
}

\section{Accessors}{
  In the following code snippets \code{x} is a VCFHeader object.
  \describe{
    \item{}{
      \code{samples(x)}:
      Returns a character() vector of names of samples. 
    }
    \item{}{
      \code{header(x)}:
      Returns all information in the header slot which includes
      \code{meta}, \code{info} and \code{geno} if present.
    }
    \item{}{
      \code{meta(x)}, \code{meta(x)<- value}: The getter returns a
      \code{DataFrameList}. Each \code{DataFrame} represents a unique
      "key" name in the header file. Multiple header lines
      with the same "key" are parsed into the same \code{DataFrame}
      with the "ID" field as the row names. Simple header lines
      have no "ID" field in which case the "key" is used as the
      row name.
 
      NOTE: In VariantAnnotation <= 1.27.5, the \code{meta()} extractor
      returned a \code{DataFrame} called "META" which held all simple
      key-value header lines. The VCF 4.3 specs allowed headers lines
      with key name "META" which caused a name clash with the pre-existing
      "META" \code{DataFrame}. 

      In \code{VariantAnnotation} >=1.27.6 the "META" \code{DataFrame} was
      split and each row became its own separate \code{DataFrame}. Calling
      \code{meta()} on a \code{VCFHeader} object now returns a list of
      \code{DataFrames}, one for each unique key name in the header.
    }
    \item{}{
      \code{fixed(x), fixed(x)<- value}:
      Returns a \code{DataFrameList} of information pertaining to any of
      \sQuote{REF}, \sQuote{ALT}, \sQuote{FILTER} and \sQuote{QUAL}. 
      Replacement value must be a \code{DataFrameList} with one or more of
      the following names, \sQuote{QUAL}, \sQuote{FILTER}, \sQuote{REF} 
      and \sQuote{ALT}. 
    }
    \item{}{
      \code{info(x)}, \code{info(x)<- value}:
      Gets or sets a \code{DataFrame} of \sQuote{INFO} information.
      Replacement value must be a \code{DataFrame} with 3 columns
      named \sQuote{Number}, \sQuote{Type} and \sQuote{Description}. 
    }
    \item{}{
      \code{geno(x)}, \code{geno(x)<- value}:
      Returns a \code{DataFrame} of \sQuote{FORMAT} information.
      Replacement value must be a \code{DataFrame} with 3 columns
      named \sQuote{Number}, \sQuote{Type} and \sQuote{Description}. 
    }
    \item{}{
      \code{reference(x)}:
      Returns a character() vector with names of reference sequences.
      Not relevant for \code{scanVcfHeader}.
    }
    \item{}{
      \code{vcfFields(x)}:
      Returns a \code{\link[IRanges]{CharacterList}} of all available VCF
      fields, with names of \code{fixed}, \code{info}, \code{geno} and
      \code{samples} indicating the four categories. Each element is a
      character() vector of available VCF field names within each category. 
    }
  }
}

\section{Arguments}{
  \describe{
    \item{reference}{A character() vector of sequences. 
    }
    \item{sample}{A character() vector of sample names. 
    }
    \item{header}{A \code{DataFrameList} of parsed header lines
    (preceeded by \dQuote{##}) present in the VCF file.
    }
    \item{...}{Additional arguments passed to methods. 
    }
  }
}

\details{
  The \code{VCFHeader} class holds header information from a
  VCF file. 

  Slots :
  \describe{
    \item{\code{reference}}{character() vector
    }
    \item{\code{sample}}{character() vector 
    }
    \item{\code{header}}{\link{DataFrameList}-class
    }
  }
}

\author{Valerie Obenchain}

\seealso{
  \code{\link{scanVcfHeader}},
  \code{\link{DataFrameList}}
}

\examples{
  fl <- system.file("extdata", "structural.vcf", package="VariantAnnotation")
  hdr <- scanVcfHeader(fl)

  fixed(hdr)
  info(hdr)
  geno(hdr)
  vcfFields(hdr)
}
