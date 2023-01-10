#' Llevar a precios constantes las bases 
#' 
#' Se puede inflar o deflactar los datos con la función. 
#' Dados los problemas en la medición de la inflación durante 2007-2015 la base es una construcción propia del CEPXXI
#' 
#' 
#' @name deflactanator
#' 
#' @param data Dataframe que se quiere deflactar/inflar
#' @param mes_base Mes que se quiere utilizar como base para inflar/deflactar. Formato: "YYYY-MM-DD"
#' @param variables_deflactar Vector con los nombres de las variables que se quieren deflactar
#' @param variable_mes Nombre de la variable que indica el mes en la base a deflactar. Dicha variable debe estar en formato "YYYY-MM-DD"
#' @param pisar_datos Valor T/F que permite pisar las variables que se deflactaron
#' @return A matrix of the infile
#' @export

deflactanator <- function(data,mes_base,variables_deflactar,variable_mes,pisar_datos=F){
  #Librerias
  require(data.table)
  load(url('https://github.com/nsidicarocep/DatosAbiertosCEP/blob/main/data/ipc_base_2016.rda?raw=true'))
  setDT(data)
  setDT(ipc_base_2016)
  setnames(ipc_base_2016,'fecha',variable_mes)
  # Elegir variable monetaria presente en la base actual
  variable_actual <- variables_deflactar
  variables_base <- colnames(data)
  #Guardar largo original de los datos 
  largo_original <- length(data)
  # Ver si solo hay una variable monetaria o más de una 
  if(length(variable_actual)==1){
    tmp <- ipc_base_2016[fecha == mes_base]
    data <- data[,indice_mes_base := tmp$indice]
    data <- merge.data.table(data,ipc_base_2016,by=variable_mes,all.x=T)
    data <- data[,indice_mes_base := indice_mes_base / indice]
    data <- data[,paste0(variable_actual,'_constante') := .SD*indice_mes_base,.SDcols=variable_actual]
    variables_base2 <- colnames(data)
    variables_base2 <- variables_base2[stringr::str_detect(variables_base2,'_constante')]
    variables_base2 <- c(variables_base,variables_base2)
    if('indice_mes_base' %in% variables_base2){
      variables_base2 <- variables_base2[!stringr::str_detect(variables_base2,'indice_mes_base')]
    }
    data <- data[,.SD,.SDcols = variables_base2]
    #return(data) 
  } else if (length(variable_actual)>1){
    tmp <- ipc_base_2016[fecha == mes_base]
    data <- data[,indice_mes_base := tmp$indice]
    data <- merge.data.table(data,ipc_base_2016,by=variable_mes,all.x=T)
    data <- data[,indice_mes_base := indice_mes_base / indice]
    data <- data[,paste0(variable_actual,'_constante') := .SD*indice_mes_base,.SDcols=variable_actual]
    variables_base2 <- colnames(data)
    variables_base2 <- variables_base2[stringr::str_detect(variables_base2,'_constante')]
    variables_base2 <- c(variables_base,variables_base2)
    if('indice_mes_base' %in% variables_base2){
      variables_base2 <- variables_base2[!stringr::str_detect(variables_base2,'indice_mes_base')]
    }
    data <- data[,.SD,.SDcols = variables_base2]
    #return(data) 
  } 
  if(length(data) > largo_original & pisar_datos == T){
    data <- data[,.SD,.SDcols = -variable_actual]
    variables_creadas <- colnames(data)
    variables_creadas <- stringr::str_remove(variables_creadas,'_constante')
    setnames(data,variables_creadas)
  }
  # } else {
  #   return(data)
  # }
}
