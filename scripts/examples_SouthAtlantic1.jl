#Let's start a temporary environment for this notebook, and add julia packages that we will use
if !isdefined(Main,:IndividualDisplacements)
    using Pkg; Pkg.activate(temp=true)
    Pkg.add.(["IndividualDisplacements", "CairoMakie", "Climatology", "NetCDF", "MeshArrays", "GeoJSON", "DataDeps"])
 
    using IndividualDisplacements, CairoMakie, Climatology, NetCDF, MeshArrays, GeoJSON, DataDeps
	p0=joinpath(dirname(pathof(IndividualDisplacements)),"..","examples")
	f0=joinpath(p0,"worldwide","OCCA_FlowFields.jl")
	include(f0);
end

# Ocean Circulation setup

P,D=OCCA_FlowFields.setup(nmax=5) #parameters, diagnostics
G=D.Γ #grid parameters
rec=OCCA_FlowFields.custom🔴 #recorder
proc=OCCA_FlowFields.custom🔧 #processor
step_forward! =∫! #integrate over time

# Southern Atlantic
nf=10*1000; lo=(-40.0,30.0); la=(-6.0,-6.0); level=2.5
df=OCCA_FlowFields.initial_positions(G, nf, lo, la, level)
I=Individuals(P,df.x,df.y,df.z,df.f,(🔴=rec,🔧=proc, 𝐷=D))
T=(0.0,10*10*86400.0)
step_forward!(I,T)

# Now we have two ways to add land background. Please try both ways and choose the one you like.
# I recommend the second way.
lon180(x)=Float64(x>180.0 ? x-360.0 : x)  # define a function to convert 0-360 to -180-180 
lon_p = (-70,40) # set longitude range you wanna plot, note indices are in the range of -180-180
lat_p = (-30,30) # set latitude range you wanna plot

# visulation 1

"""
    myplot1(I::Individuals)

Plot the initial and final positions as scatter plot in `lon,lat` or `x,y` plane.
"""

fil=demo.download_polygons("countries.geojson") # using MeshArrays to get countries' map
pol=MeshArrays.read_polygons(fil);
function myplot1(I::Individuals)
	🔴_by_t = IndividualDisplacements.DataFrames.groupby(I.🔴, :t)
	set_theme!(theme_black())
    fig=Figure(size = (600, 400))
    a = Axis(fig[1, 1],xlabel="longitude",ylabel="latitude")		
    scatter!(a,lon180.(🔴_by_t[1].lon),🔴_by_t[1].lat,color=:green2,markersize=4,label="initial positions") # use lon180 to convert longitude range
    scatter!(a,lon180.(🔴_by_t[end].lon),🔴_by_t[end].lat,color=:red,markersize=4,label="final positions") 
    [lines!(a,l1,color = :white, linewidth = 0.5) for l1 in pol] # countries are -180-180

    xlims!(a,lon_p)
    ylims!(a,lat_p)
    axislegend(a)
    return fig
end
myplot1(I)
#fig = myplot1(I)
#save("/Users/yysong/Desktop/study/ECCO-202410/figures/mask_test1.png",fig)

# visulation 2

"""
    myplot2(I::Individuals)

Plot the initial and final positions as scatter plot in `lon,lat` or `x,y` plane.
"""
γ=GridSpec("PeriodicChannel",MeshArrays.GRID_LL360) # using MeshArrays to get Grid information
Γ=GridLoad(γ;option="full")
lndid = findall(Γ.hFacC[1,1].==0); # find indices of all positions of land
function myplot2(I::Individuals)
	🔴_by_t = IndividualDisplacements.DataFrames.groupby(I.🔴, :t)
	set_theme!(theme_black())
    fig=Figure(size = (600, 400))
    a = Axis(fig[1, 1],xlabel="longitude",ylabel="latitude")	
    
    scatter!(a,lon180.(🔴_by_t[1].lon),🔴_by_t[1].lat,color=:green2,markersize=4,label="initial positions") # use lon180 to convert longitude range
    scatter!(a,lon180.(🔴_by_t[end].lon),🔴_by_t[end].lat,color=:red,markersize=4,label="final positions") 
    scatter!(a,lon180.(Γ.XC[1,1][lndid]),Γ.YC[1,1][lndid],color=:white,markersize=7) # scatter the land background

    xlims!(a,lon_p)
    ylims!(a,lat_p)
    axislegend(a)
    return fig
end
myplot2(I)
    
