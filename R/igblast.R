#' Run IgDiscover for IgBlast using reticulate and conda environment
#'
#' @param database Vector containing the database for VDJ sequences
#' @param fasta Vector containing the sequences, usually a column from a data.frame. eg. df$sequences
#' 
#' @return Creates a data frame with the Igblast analysis where each row is the tested sequence with columns containing the results for each sequence
#' @import reticulate here basilisk
#' @examples
#' ## Example with test sequences
#' igblast(
#'     database = system.file("inst/extdata/test_fasta/KIMDB_rm"),
#'                                 ,
#'     fasta = system.file("inst/extdata/test_fasta/test_igblast.txt")
#' )
#' @export


igblast <- function(database = "path/to/folder", fasta = "path/to/file", threads = 1) {
  db_dir <- here(database)
  fasta_dir <- here(fasta) 
  
  #db_dir <- here("inst", "extdata", "test_fasta", "KIMDB_rm")
  #fasta_dir <- here("inst", "extdata", "test_fasta")
  
  if (dir.exists(db_dir)) {
    print(paste("The database directory", db_dir, "exists."))
  } else {
    stop(paste("The database directory", db_dir, "does not exist."))
  }
  
  if (file.exists(fasta_dir)) {
    print(paste("The fasta file directory", fasta_dir, "exists."))
  } else {
    stop(paste("The fasta file directory", fasta_dir, "does not exist."))
  }
  
  proc <- basiliskStart(env)
  on.exit(basiliskStop(proc))
  
  run_igblastwrap <- basiliskRun(proc, fun=function(arg1, arg2, arg3) {
    
    try(source_python("inst/script/igblastwrap.py"), silent = TRUE)
    #source_python("inst/script/igblastwrap.py")
    df <- system(paste("python inst/script/igblastwrap.py --threads", threads,  database, fasta , sep = " "),
                 intern = TRUE)  
    
    results_airr = read.table(text = df, header = TRUE, sep = "\t")
    
    return(final_output = results_airr)
    
  }, arg1=database, arg2=fasta, arg3=threads)
  
  run_igblastwrap
}



