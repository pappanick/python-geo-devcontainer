"""Example geoprocessing script."""

from osgeo import gdal


def main() -> None:
	"""Print GDAL version and available drivers."""
	print(f'GDAL version: {gdal.__version__}')
	print(f'Available raster drivers: {gdal.GetDriverCount()}')

	# Try importing esa_snappy (only available in full image)
	try:
		import esa_snappy

		print('esa_snappy: available')
	except ImportError:
		print('esa_snappy: not available (use full Dockerfile for SNAP support)')


if __name__ == '__main__':
	main()
