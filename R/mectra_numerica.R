#' Convierte todas las variables numericas de mectra en double
#'
#' Hace más rápido el proceso de pasar los integer y las string que deberian ser double a double 
#'
#' @name mectra_numerica
#' 
#'
#' @param data Nombre del elemento al que se quiere añadir las etiquetas
#' @return A matrix of the infile
#' @export

# Armar funcion
mectra_numerica <- function(data) {
  require(data.table)
  setDT(data)
  #Variables que pueden pasar a numericas 
  numericas_posibles <- c('cuit','cuil','clae6','act_trab','codprov','remuneracion','sueldo','sac','conss','conos','madconss','conrenatre','codobsoc','cond_cuil','apobliss','apobsoc','convencionado','modalidad','mes')
  numericas <- numericas_posibles[numericas_posibles %in% colnames(data)]
  data <- data[,lapply(.SD, as.double),.SDcols=numericas]
}
