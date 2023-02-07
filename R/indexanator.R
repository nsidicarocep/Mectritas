#' Genera un índice sobre cada variable seleccionada
#' 
#' Sirve para generar un índice en base 100 según el valor del índice seleccionado
#' La relatividad de los datos puede ser en función del valor máximo, mínimo o de un mes en particular
#' 
#' @name indexanator
#' 
#' @param data Dataframe que se quiere deflactar/inflar
#' @param base_indice Indica sobre que valor se quiere indexar el dato: min, max o fecha YYYY-MM-DD
#' @param variables_indexar Vector con los nombres de las variables que se quieren deflactar
#' @param variables_agrupar Nombre de la variable que indica el mes en la base a deflactar. Dicha variable debe estar en formato "YYYY-MM-DD"
#' @param pisar_datos Valor T/F que permite pisar las variables que se deflactaron
#' @return A matrix of the infile
#' @export

indexanator <- function(data,base_indice,variables_indexar,variables_agrupar='',pisar_datos=F){
  #Librerias
  require(data.table)
  setDT(data)
  #Guardar largo original de base
  largo_original <- length(data)
  # Cargar nombre de variables que pueden indexarse
  variables_datos_abiertos <- variables_indexar
  # Elegir variable monetaria presente en la base actual
  variable_actual <- names(data)
  variables_base <- names(data)
  variables_index <- variable_actual[variable_actual %in% variables_datos_abiertos]
  if(variables_agrupar == '') {
    data <- data[,no_agrupada := 1]
    variables_agrupar <- 'no_agrupada'
  }
  variables_no_index <- variables_agrupar
  if(base_indice == 'max'){
    # Indexar contra valor máximo de cada desagregacion
    tmp <- data[,lapply(.SD,max,na.rm=T),by=variables_no_index,.SDcols=variables_index]
    setnames(tmp, (length(variables_no_index)+1):length(tmp), paste0(names(tmp)[(length(variables_no_index)+1):length(tmp)], '_max'))
    #Joinear para agregar los datos buscados de cada variable 
    data <- merge.data.table(data,tmp,by=variables_no_index,all.x=T)
    # Calcular el indice sobre cada variable
    variable_index2 <- c(variables_index,paste0(variables_index,'_max'))
    for(j in 1:length(variables_index)){
      data <- data[,paste0(variables_index[j],'_index') := .SD[[j]] * 100 / .SD[[j+length(variables_index)]],.SDcols = variable_index2]
    }
    #Seleccionar columnas originales y las que tienen index
    variables_temporales <- colnames(data)[stringr::str_detect(colnames(data),'_max')]
    data <- data[,.SD,.SDcols = -variables_temporales]
  } else if (base_indice == 'min') {
   
    # Indexar contra valor minimo de cada desagregacion
    tmp <- data[,lapply(.SD,min,na.rm=T),by=variables_no_index,.SDcols=variables_index]
    setnames(tmp, (length(variables_no_index)+1):length(tmp), paste0(names(tmp)[(length(variables_no_index)+1):length(tmp)], '_min'))
    #Joinear para agregar los datos buscados de cada variable 
    data <- merge.data.table(data,tmp,by=variables_no_index,all.x=T)
    # Calcular el indice sobre cada variable
    variable_index2 <- c(variables_index,paste0(variables_index,'_min'))
    for(j in 1:length(variables_index)){
      data <- data[,paste0(variables_index[j],'_index') := .SD[[j]] * 100 / .SD[[j+length(variables_index)]],.SDcols = variable_index2]
    }
    #Seleccionar columnas originales y las que tienen index
    variables_temporales <- colnames(data)[stringr::str_detect(colnames(data),'_min')]
    data <- data[,.SD,.SDcols = -variables_temporales]
    
  } else if (stringr::str_detect(base_indice,'[0-9]{4}-[0-9]{2}-[0-9]{2}')) {
    tmp <- data[fecha == base_indice]
    tmp <- tmp[,.SD,.SDcols = c(variables_no_index,variables_index)]
    if('fecha' %in% variables_no_index){
      tmp$fecha <- NULL
    }
    setnames(tmp, (length(variables_no_index)+1):length(tmp), paste0(names(tmp)[(length(variables_no_index)+1):length(tmp)], '_mes'))
    #Joinear para agregar los datos buscados de cada variable 
    data <- merge.data.table(data,tmp,by=variables_no_index,all.x=T)
    # Calcular el indice sobre cada variable
    variable_index2 <- c(variables_index,paste0(variables_index,'_mes'))
    for(j in 1:length(variables_index)){
      data <- data[,paste0(variables_index[j],'_index') := .SD[[j]] * 100 / .SD[[j+length(variables_index)]],.SDcols = variable_index2]
    }
    
    #Seleccionar columnas originales y las que tienen index
    variables_temporales <- colnames(data)[stringr::str_detect(colnames(data),'_mes')]
    data <- data[,.SD,.SDcols = -variables_temporales]
  } else {
    warning(paste0('No se detectó correctamente la base indicada para generar el índice.\n 
                   Las opciones son: max, min o una fecha en formato YYYY-MM-DD')) 
    return(data)
  }
  if(variables_agrupar == 'no_agrupada') {
    data$no_agrupada <- NULL
  }
  if(length(data) > largo_original & pisar_datos == T){
    data <- data[,.SD,.SDcols = -variables_index]
    variables_creadas <- colnames(data)
    variables_creadas <- stringr::str_remove(variables_creadas,'_index')
    setnames(data,variables_creadas)
  } else {
    return(data)
  }
}
