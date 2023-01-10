#' Eliminar o indicar cuits publicos y no utiles
#'
#' Permite identificar rápidamente cuits públicos o de cajas provinciales para indicar cuales son o eliminarlos de la base 
#'
#' @name limpia_cuits
#' 
#'
#' @param data Nombre del elemento al que se quiere añadir las etiquetas
#' @param elimina_cajas Se sacan las cajas provinciales y otros cuits no utilizados. Default == T 
#' @param indica_cajas Indica si el CUIT refiere a una caja o no. Default == F, ya que se suelen eliminar
#' @param elimina_publico Se sacan los cuits publicos. Default == F 
#' @param indica_publico Indica si el CUIT es publico o no y el tipo de CUIT público. Inclusion 1 indica que es público productivo, 0 que no lo es y 2 que no es público
#' @param elimina_pub_no_prod Se sacan los cuits públicos no productivos (inclusion == 0). Default == F
#' @return A matrix of the infile
#' @export

# Armar funcion
limpia_cuits <- function(data, elimina_cajas=T,indica_cajas=F,elimina_publico=F,indica_publico=T,elimina_pub_no_prod = F) {
  require(data.table)
  setDT(data)
  filtro_database <- Mectritas::filtro_database 
  cuits_publicos <- Mectritas::cuits_publicos
  # Elimina cajas 
  if(elimina_cajas == T){
    data <- data[!(cuit %in% filtro_database)]
  }
  
  # Indica cajas  
  if(indica_cajas == T){
    data <- data[,cajas := fifelse(cuit %in% filtro_database$cuit,1,0)]
  }
  
  # Elimina publico 
  if(elimina_publico == T){
    data <- data[!(cuit %in% cuits_publicos$cuit)]
  }
  
  # Indica publico 
  if(indica_publico == T){
    data <- merge.data.table(data,cuits_publicos,by='cuit',all.x=T)
    data <- data[,inclusion := tidyr::replace_na(inclusion,2)]
  }
  
  # Elimina no productivos 
  if(elimina_pub_no_prod == T){
    data <- data[!(cuit %in% cuits_publicos[inclusion == 0]$cuit)]
  }
  return(data)
}
